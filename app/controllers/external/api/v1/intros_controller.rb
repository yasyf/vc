class External::Api::V1::IntrosController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def create
    IntroRequest.from_target_investor! TargetInvestor.find(intro_request_params[:target_investor_id])
    render json: {}
  end

  private

  def intro_request_params
    params.require(:intro_request).permit(:target_investor_id)
  end
end
