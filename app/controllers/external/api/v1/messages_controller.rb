class External::Api::V1::MessagesController < External::Api::V1::ApiV1Controller
  PASS_PHRASES = ['keep in touch', 'not interested', 'not right now']

  before_action :check_signature unless Rails.env.development?

  def create
    from = Mail::Address.new(create_params[:from])
    to = Mail::Address.new(create_params[:to])

    if (founder = Founder.where(email: from.address).first).present?
      create_outgoing founder, to
    else
      founder = Founder.where(email: to.address).first!
      create_incoming founder, from
    end

    head :ok
  end


  private

  def text
    create_params['stripped-text']
  end

  def sentiment
    @sentiment ||= GoogleCloud::Language.new(text).sentiment
  end

  def create_outgoing(founder, to)
    stage =  TargetInvestor::RAW_STAGES.keys.index(:waiting)
    target = TargetInvestor.from_addr founder, to

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

    target.email ||= to.address
    target.stage = stage
    target.save!
  end

  def create_incoming(founder, from)
    stage =
      if sentiment.negative? && PASS_PHRASES.any? { |p| p.in?(text) }
        TargetInvestor::RAW_STAGES.keys.index(:pass)
      else
        TargetInvestor::RAW_STAGES.keys.index(:respond)
      end
    target = TargetInvestor.from_addr founder, from

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
    params.permit(:to, :from, 'stripped-text')
  end

  def check_signature
    digest = OpenSSL::Digest::SHA256.new
    signature = OpenSSL::HMAC.hexdigest(digest, ENV["MAILGUN_API_KEY"], [params[:timestamp], params[:token]].join)
    head :unauthorized unless params[:signature] == signature
  end
end
