class External::VCWiz::InvestorsController < External::FrontendController
  before_action :check_investor!, only: [:contacts, :settings]

  def index
    if external_investor_signed_in?
      redirect_to action: :contacts
    else
      redirect_to action: :signup
    end
  end

  def token
    investor = Investor.with_token(params[:token]).first!
    sign_in_external_investor! investor
    if params[:email].present?
      investor.email = params[:email]
      investor.save_and_fix_duplicates!
    end
    redirect_to action: :index
  end

  def impersonate
    investor = Investor.find(params[:investor_id])
    head :unauthorized and return unless investor.competitor == current_external_investor.competitor
    sign_in_external_investor! investor
    redirect_to action: :settings
  end

  def signup
    title 'Investor Login'
    component 'InvestorSignup'
    render_default
  end

  def contacts
    contacts = current_partners.where(email: nil).limit(10)
    redirect_to action: :settings and return unless contacts.present?

    title 'Investor Signup'
    component 'InvestorContacts'
    investor_props contacts: contacts.map(&:as_light_json)
    render_default
  end

  def update_contacts
    if params[:emails].present?
      JSON.parse(params[:emails]).each do |id, email|
        address = Mail::Address.new(email) rescue next
        investor = Investor.find(id)
        investor.email = address.address
        investor.save_and_fix_duplicates!
        next unless investor.email.present?
        InvestorMailer.invite_email(investor.id, current_external_investor.id).deliver_later
      end
      flash_success 'Your colleagues have been invited!'
    end
    redirect_to action: :settings
  end

  def settings
    companies = records_to_options(current_external_investor.companies.map(&:as_json_search))
    industries = hash_to_options(Competitor::INDUSTRIES.slice(*(current_external_investor.industry || [])))
    partners = current_partners.map(&:as_light_json)

    title 'Investor Settings'
    component 'InvestorSettings'
    investor_props companies: companies, industries: industries, partners: partners
    render_default
  end

  private

  def current_partners
    current_external_investor
      .competitor
      .investors
      .where.not(id: current_external_investor.id)
      .where(hidden: false)
  end

  def investor_props(other_props = {})
    props other_props.merge(investor: current_external_investor.as_json(only: nil, methods: [:competitor, :al_username]))
  end

  def render_default
    render html: '', layout: 'vcwiz'
  end
end
