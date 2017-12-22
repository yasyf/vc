class External::VCWiz::InvestorsController < External::ApplicationController
  include External::ApplicationHelper
  include External::Concerns::Reactable

  layout 'vcwiz'
  before_action :check_investor!, only: [:settings]

  def index
    if external_investor_signed_in?
      redirect_to action: :settings
    else
      redirect_to action: :signup
    end
  end

  def token
    investor = Investor.with_token(params[:token]).first!
    sign_in_external_investor! investor
    investor.update! email: params[:email] if params[:email].present?
    redirect_to action: :index
  end

  def signup
    title 'Investor Signup'
    component 'InvestorSignup'
    render_default
  end

  def settings
    companies = records_to_options(current_external_investor.companies.map(&:as_json_search))
    industries = hash_to_options(Competitor::INDUSTRIES.slice(*(current_external_investor.industry || [])))

    title 'Investor Settings'
    component 'InvestorSettings'
    props investor: current_external_investor.as_json(only: nil, methods: [:competitor, :al_username]), companies: companies, industries: industries
    render_default
  end

  private

  def render_default
    render html: '', layout: 'vcwiz'
  end
end
