class Message
  PASS_PHRASES = [
    'keep in touch',
    'not interested',
    'not right now',
    'not a good fit',
    'keep in touch',
    'i can be helpful',
  ]

  def initialize(message)
    @message = message
  end

  def from
    @from ||= Mail::Address.new header('From')
  end

  def to
    @to ||= Mail::Address.new header('To')
  end

  def date
    @date ||= begin
      date = header('Date')
      date.present? ? DateTime.parse(date) : DateTime.now
    end
  end

  %w(cc bcc).each do |s|
    define_method(s) do
      unless instance_variable_defined?("@#{s}")
        string = header(s.capitalize)
        result = string.present? ? Mail::AddressList.new(string).addresses : []
        instance_variable_set("@#{s}", result)
      end
      instance_variable_get("@#{s}")
    end
  end

  def recipients
    [to] + cc + bcc
  end

  def sent_to?(address)
    recipients.any? { |addr| addr.address == address }
  end

  def headers
    @headers ||= @message.payload.headers.map { |h| [h.name, h.value] }.to_h.with_indifferent_access
  end

  def header(name)
    headers[name]
  end

  def subject
    @subject ||= header('Subject')
  end

  def text
    @text ||= part('text/plain')&.data || ''
  end

  def html
    @html ||= part('text/html')&.data || ''
  end

  def reply_text
    @reply_text ||= EmailReplyParser.parse_reply(text)
  end

  def sentiment
    @sentiment ||= GoogleCloud::Language.new(Util.fix_encoding(reply_text)).sentiment
  end

  def intro_request
    @intro_request ||= self.class.intro_request(text)
  end

  def process!(founder)
    return if sent_to?(ENV['MAILGUN_EMAIL'])
    if from.address == founder.email || from.name == founder.name
      process_outgoing!(founder)
    else
      process_incoming!(founder)
    end
  end

  private

  def part(type)
    @message.payload.parts&.find { |part| part.mime_type == type}&.body
  end

  def process_incoming!(founder)
    founder.connect_from_addr!(from, :email)
    target = TargetInvestor.from_addr(founder, from, create: true)
    return unless target.present?
    stage = self.class.stage(reply_text, sentiment)
    if target.investor.present?
      email = Email.create!(
        intro_request: intro_request,
        founder: founder,
        investor: target.investor,
        company: founder.primary_company,
        direction: :incoming,
        old_stage: target.stage,
        new_stage: stage,
        sentiment_score: sentiment&.score,
        sentiment_magnitude: sentiment&.magnitude,
        body: reply_text,
        subject: subject,
        created_at: date,
      )
      target.investor_replied!(intro_request&.id, email.id).tap do |event|
        event.update! created_at: date
      end
    end
    target.email ||= from.address
    target.stage = stage
    target.save!
  end

  def process_outgoing!(founder)
    recipients.each do |addr|
      founder.connect_to_addr!(addr, :email)
      target = TargetInvestor.from_addr(founder, addr, create: true)
      next unless target.present?
      stage =  TargetInvestor::RAW_STAGES.keys.index(:waiting)
      Email.create!(
        intro_request: intro_request,
        founder: founder,
        investor: target.investor,
        company: founder.primary_company,
        direction: :outgoing,
        old_stage: target.stage,
        new_stage: stage,
        sentiment_score: sentiment&.score,
        sentiment_magnitude: sentiment&.magnitude,
        body: reply_text,
        subject: subject,
        created_at: date,
      ) if target.investor.present?
      target.email ||= addr.address
      target.stage = stage
      target.save!
    end
  end

  def self.stage(text, sentiment)
    if sentiment&.negative? && PASS_PHRASES.any? { |p| p.in?(text.downcase) }
      TargetInvestor::RAW_STAGES.keys.index(:pass)
    else
      TargetInvestor::RAW_STAGES.keys.index(:respond)
    end
  end

  def self.intro_request(source)
    return nil unless source.present?
    match = /#{IntroRequest::TOKEN_MAGIC}([\w]{10})/.match(source)
    IntroRequest.where(token: match[1]).first if match.present?
  end
end