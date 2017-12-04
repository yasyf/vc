class External::Api::V1::MessagesController < External::Api::V1::ApiV1Controller
  YES_PHRASES = %w(yes y yea yeah yup)
  NO_PHRASES = %w(no n nope)

  before_action :check_signature if Rails.env.production?

  def create
    if (founder = founder_from_from).present?
      create_outgoings founder, to_addrs
    else
      founders = existing_emails Founder, to_addrs
      if founders.present?
        create_incomings founders, from_addr
      else
        handle_response from_addr, to_addrs
      end
    end

    head :ok
  end

  def demo
    return head :not_acceptable unless (founder = founder_from_from).present?
    target = TargetInvestor.from_addr!(founder, ENV['DEMO_EMAIL']).tap(&:investor_opened!)
    DemoMailer.demo_email(founder, target, demo_params[:subject]).deliver_later
    head :ok
  end

  def open
    return head :ok unless intro_request.present?
    return head :ok unless recipient.address == intro_request.investor.email
    recipient_target.investor_opened! intro_request.id
    intro_request.update!(
      opened_at: DateTime.now,
      open_city: hook_params['city'],
      open_country: hook_params['country'],
      open_device_type: hook_params['device-type'],
    )
    head :ok
  end

  def click
    return head :ok unless intro_request.present?
    return head :ok unless recipient.address == intro_request.investor.email
    recipient_target.investor_clicked! intro_request.id, hook_params['url']
    intro_request.update!(
      open_city: hook_params['city'],
      open_country: hook_params['country'],
      open_device_type: hook_params['device-type'],
    )
    intro_request.add_domain!(hook_params['url'])
    head :ok
  end

  private

  def founder_from_from
    @founder_from_from ||= Founder.where(email: from_addr.address).first
  end

  def from_addr
    @from_addr ||= Mail::Address.new(create_params[:From])
  end

  def to_addrs
    @to_addrs ||= begin
      tos = create_params[:To].split(', ').map { |s| Mail::Address.new(s) }
      if create_params[:Cc].present?
        tos += create_params[:Cc].split(', ').map { |s| Mail::Address.new(s) }
      end
      tos.delete_if { |a| a.address == ENV['MAILGUN_EMAIL'] }
      tos
    end
  end

  def recipient
    @recipient ||= Mail::Address.new(hook_params[:recipient])
  end

  def recipient_target
    @recipient_target ||= TargetInvestor.from_addr(intro_request.founder, recipient)
  end

  def existing_emails(klass, tos)
    tos.inject(klass.none) { |scope, to| scope.or(klass.where(email: to.address)) }
  end

  def text
    create_params['stripped-text']
  end

  def body
    create_params['body-plain']
  end

  def headers
    @headers ||= JSON.parse(create_params['message-headers'] || '[]').to_h
  end

  def sentiment
    @sentiment ||= GoogleCloud::Language.new(text).sentiment
  end

  def intro_request
    @intro_request ||= intro_request_from_header || intro_request_from_body
  end

  def intro_request_from_header
    token = hook_params['intro_request_token'] || (headers['X-Mailgun-Variables'] || {})['intro_request_token']
    Messages.intro_request token
  end

  def intro_request_from_body
    Messages.intro_request body
  end

  def handle_response(from, tos)
    investor = Investor.where(email: from.address).first
    return unless investor.present?
    return unless intro_request.present?

    if intro_request.decided?
      intro_request.update! reason: text
      return
    end

    if YES_PHRASES.any? { |s| s == text.downcase }
      intro_request.decide! true
    elsif NO_PHRASES.any? { |s| s == text.downcase }
      intro_request.decide! false
    end
  end

  def create_outgoings(founder, tos)
    existing = existing_emails Investor, tos
    if existing.present?
      existing.each { |investor| create_outgoing_from_investor(founder, investor) }
    else
      tos.each { |to| create_outgoing_from_addr(founder, to) }
    end
  end

  def create_outgoing_from_investor(founder, investor)
    target = TargetInvestor.from_investor! founder, investor
    target.email ||= investor.email
    target.save! if target.changed?
    create_outgoing_from_target founder, target
  end

  def create_outgoing_from_addr(founder, to)
    target = TargetInvestor.from_addr! founder, to
    target.email ||= to.address
    target.save! if target.changed?
    create_outgoing_from_target founder, target
  end

  def create_outgoing_from_target(founder, target)
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
      subject: create_params[:Subject]
    ) if target.investor.present?

    target.stage = stage
    target.save!
  end

  def create_incomings(founders, from)
    founders.each { |founder| create_incoming(founder, from) }
  end

  def create_incoming(founder, from)
    stage = Messages.stage(text, sentiment)
    target = TargetInvestor.from_addr! founder, from

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
        subject: create_params[:Subject]
      )
      target.investor_replied! intro_request&.id, email.id
    end

    target.email ||= from.address
    target.stage = stage
    target.save!
  end

  def hook_params
    params.permit('intro_request_token', 'country', 'city', 'device-type', 'url', 'recipient')
  end

  def create_params
    params.permit(:To, :From, :Cc, :Subject, 'stripped-text', 'body-plain', 'message-headers')
  end

  def demo_params
    params.permit(:subject)
  end

  def check_signature
    digest = OpenSSL::Digest::SHA256.new
    signature = OpenSSL::HMAC.hexdigest(digest, ENV['MAILGUN_API_KEY'], [params[:timestamp], params[:token]].join)
    head :unauthorized unless params[:signature] == signature
  end
end
