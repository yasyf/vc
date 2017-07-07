class External::Api::V1::InvestorsController < External::Api::V1::ApiV1Controller
  def search
    render json: { results: Investor.fuzzy_search(params[:q]) }
  end
end
