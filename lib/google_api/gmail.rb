require 'google/apis/gmail_v1'

module GoogleApi
  class Gmail < Base
    SCOPES = [Google::Apis::GmailV1::AUTH_GMAIL_READONLY]

    def initialize(user)
      @user = user
      @gmail = Google::Apis::GmailV1::GmailService.new
      @gmail.authorization = authorization
      @gmail.quota_user = @user.id.to_s
      @gmail.user_ip = @user.ip_address.to_s
    end

    def sync!
      if @user.history_id.present?
        sync_partial!
      else
        sync_full!
      end
    end

    private

    def sync_partial!
      begin
        response = list_histories
      rescue Google::Apis::ClientError
        sync_full!
        return
      end

      return unless response.history.present?
      loop do
        message_ids = response.history.flat_map do |history|
          history.messages_added.reject { |ma| ma.message.label_ids&.include?('DRAFT') }.map { |ma| ma.message.id }
        end.uniq
        get_messages(message_ids) do |message|
          process_message message
        end
        unless response.next_page_token.present?
          @user.update! history_id: response.history_id
          break
        end
        response = list_histories response.next_page_token
      end
    end

    def sync_full!
      response = list_threads
      history_id = response.threads.first.history_id
      loop do
        thread_ids = response.threads.map(&:id)
        get_threads(thread_ids)  do |thread|
          process_thread thread
        end
        break unless response.next_page_token.present?
        response = list_threads response.next_page_token
      end
      @user.update! history_id: history_id
    end

    def process_thread(thread)
      thread.messages.last(2).each do |message|
        process_message(message)
      end
    end

    def process_message(message)
      Message.new(message).process!(@user)
    end

    %w(thread message).each do |s|
      define_method("get_#{s}s") do |ids, &block|
        @gmail.batch do |batch|
          ids.each do |id|
            batch.public_send("get_user_#{s}", @user.email, id) do |res, err|
              raise err if err.present?
              block.call(res)
            end
          end
        end
      end
    end

    def list_histories(token = nil)
      @gmail.list_user_histories(@user.email, history_types: 'messageAdded', start_history_id: @user.history_id, page_token: token)
    end

    def list_threads(token = nil, limit = '6m')
      @gmail.list_user_threads(@user.email, page_token: token, q: "newer_than:#{limit}")
    end
  end
end

class Message
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
        result = string.present? ? string.split(', ').map { |a| Mail::Address.new(a) } : []
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
    @text ||= part('text/plain').data
  end

  def html
    @html ||= part('text/html').data
  end

  def sentiment
    @sentiment ||= GoogleCloud::Language.new(text).sentiment
  end

  def intro_request
    @intro_request ||= Messages.intro_request(text)
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
    @message.payload.parts.find { |part| part.mime_type == type}.body
  end

  def process_incoming!(founder)
    target = TargetInvestor.from_addr(founder, from, create: true)
    return unless target.present?
    stage = Messages.stage(text, sentiment)
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
        body: text,
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
        body: text,
        subject: subject,
        created_at: date,
      ) if target.investor.present?
      target.email ||= addr.address
      target.stage = stage
      target.save!
    end
  end
end