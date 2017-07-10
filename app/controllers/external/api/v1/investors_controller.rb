class External::Api::V1::InvestorsController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def search
    existing = current_external_founder.target_investors
    render json: Investor.includes(:competitor).fuzzy_search(params[:q]).where.not(id: existing)
  end
end
