class External::Api::V1::InvestorsController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def search
    existing = current_external_founder.target_investors.select('investor_id')
    render json: Investor.includes(:competitor).fuzzy_search(params[:q]).where.not(id: existing)
  end
end
