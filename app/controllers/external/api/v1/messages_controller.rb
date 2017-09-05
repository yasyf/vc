class External::Api::V1::MessagesController < External::Api::V1::ApiV1Controller
  PASS_PHRASES = ['keep in touch', 'not interested', 'not right now']
  YES_PHRASES = %w(yes y yea yeah yup)
  NO_PHRASES = %w(no n nope)

  before_action :check_signature unless Rails.env.development?

  def create
    from = Mail::Address.new(create_params[:From])
    tos = create_params[:To].split(', ').map { |s| Mail::Address.new(s) }
    if create_params[:Cc].present?
      tos += create_params[:Cc].split(', ').map { |s| Mail::Address.new(s) }
    end
    tos.delete_if { |a| a.domain == ENV['MAILGUN_EMAIL'].split('@').last }

    if (founder = Founder.where(email: from.address).first).present?
      create_outgoings founder, tos
    else
      founders = existing_emails Founder, tos
      if founders.present?
        create_incomings founders, from
      else
        handle_response from, tos
      end
    end

    head :ok
  end

  private

  def existing_emails(klass, tos)
    tos.inject(klass.none) { |scope, to| scope.or(klass.where(email: to.address)) }
  end

  def text
    create_params['stripped-text']
  end

  def body
    create_params['body-plain']
  end

  def sentiment
    @sentiment ||= GoogleCloud::Language.new(text).sentiment
  end

  def intro_request
    @intro_request ||= begin
      match = /#{IntroRequest::TOKEN_MAGIC}([\w]{10})/.match(body)
      IntroRequest.where(token: match[1]).first if match.present?
    end
  end

  def handle_response(from, tos)
    investor = Investor.where(email: from.address).first
    return unless investor.present?
    return unless intro_request.present?

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
      founder: founder,
      investor: target.investor,
      company: founder.primary_company,
      direction: :outgoing,
      old_stage: target.stage,
      new_stage: stage,
      sentiment_score: sentiment.score,
      sentiment_magnitude: sentiment.magnitude,
      body: text,
    ) if target.investor.present?

    target.stage = stage
    target.save!
  end

  def create_incomings(founders, from)
    founders.each { |founder| create_incoming(founder, from) }
  end

  def create_incoming(founder, from)
    stage =
      if sentiment.negative? && PASS_PHRASES.any? { |p| p.in?(text) }
        TargetInvestor::RAW_STAGES.keys.index(:pass)
      else
        TargetInvestor::RAW_STAGES.keys.index(:respond)
      end
    target = TargetInvestor.from_addr! founder, from

    Email.create!(
      founder: founder,
      investor: target.investor,
      company: founder.primary_company,
      direction: :incoming,
      old_stage: target.stage,
      new_stage: stage,
      sentiment_score: sentiment.score,
      sentiment_magnitude: sentiment.magnitude,
      body: text,
    ) if target.investor.present?

    target.email ||= from.address
    target.stage = stage
    target.save!
  end

  def create_params
    params.permit(:To, :From, :Cc, 'stripped-text', 'body-plain')
  end

  def check_signature
    digest = OpenSSL::Digest::SHA256.new
    signature = OpenSSL::HMAC.hexdigest(digest, ENV["MAILGUN_API_KEY"], [params[:timestamp], params[:token]].join)
    head :unauthorized unless params[:signature] == signature
  end
end
