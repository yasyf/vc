class External::Api::V1::InvestorsController < External::Api::V1::ApiV1Controller
  def index
    render json: { investors: current_external_founder.target_investors }
  end
end
