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
    @text ||= Util.fix_encoding(part('text/plain')&.data) || ''
  end

  def html
    @html ||= Util.fix_encoding(part('text/html')&.data) || ''
  end

  def id
    @message.id
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

  def process!(founder, skip_graph = false)
    return if sent_to?(ENV['MAILGUN_EMAIL'])
    if from.address == founder.email || from.name == founder.name
      process_outgoing!(founder, skip_graph)
    else
      process_incoming!(founder, skip_graph)
    end
  rescue Mail::Field::IncompleteParseError
    # ignored
  end

  private

  def part(type)
    if @message.payload.parts.present?
      @message.payload.parts.find { |part| part.mime_type == type}&.body
    elsif @message.payload.mime_type == type
      @message.payload.body
    end
  end

  def process_incoming!(founder, skip_graph)
    founder.connect_from_addr!(from, :email) if valid_connection?(from) && !skip_graph
    target = TargetInvestor.from_addr(founder, from, create: true)
    return unless target.present?
    stage = self.class.stage(reply_text, sentiment)
    if target.investor.present?
      email = Email.where(email_id: id).first_or_create!(
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
      return unless email.id_previously_changed?
      target.investor_replied!(intro_request&.id, email.id).tap do |event|
        event.update! created_at: date
      end
    end
    target.email ||= from.address
    target.stage = stage
    target.save!
  end

  def process_outgoing!(founder, skip_graph)
    recipients.each do |addr|
      founder.connect_to_addr!(addr, :email) if valid_connection?(addr) && !skip_graph
      target = TargetInvestor.from_addr(founder, addr, create: true)
      next unless target.present?
      stage =  TargetInvestor::RAW_STAGES.keys.index(:waiting)
      if target.investor.present?
        email = Email.where(email_id: id).first_or_create!(
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
        )
        return unless email.id_previously_changed?
      end
      target.email ||= addr.address
      target.stage = stage
      target.save!
    end
  end

  def valid_connection?(addr)
    !invalid_email_for_connections? && addr.domain != ENV['MARKETING_DOMAIN']
  end

  def invalid_email_for_connections?
    @invalid_email_for_connections ||= begin
      [
       'unsubscribe',
       'email preferences',
       'privacy policy',
       'terms of use',
       'do not reply',
       'you have received this email because',
       'you are receiving this email',
       'view in your browser',
       'to stop receiving',
       '©',
       'could not be delivered',
       "wasn't delivered",
      ].any? { |s| text&.downcase&.include?(s) || html&.downcase&.include?(s) } ||
      %w(
        List-Unsubscribe
        List-ID
        X-Mailgun-Sid
        Feedback-ID
        X-SES-Outgoing
        X-SG-EID
        X-MC-User
        X-Mandrill-User
        X-Roving-ID
        X-Eventbrite
       ).any? { |h| headers.key?(h) } ||
      recipients.push(from).any? do |a|
        (a.local.present? && (%w(noreply no-reply do-not-reply daemon notification support orders team help info admin master).any? { |s| a.local.downcase.include?(s) } || a.local.include?('+'))) ||
        (a.name.present? && (['mail delivery', 'support', 'team', 'subsystem', 'accounting', 'payroll', 'admin', 'clara thompson'].any? { |s| a.name.downcase.include?(s) }))
      end
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