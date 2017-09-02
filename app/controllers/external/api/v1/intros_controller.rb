class External::Api::V1::IntrosController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def create
    IntroRequest.create! intro_request_params
    render json: {}
  end

  private

  def intro_request_params
    params.require(:intro_request).permit(:investor_id, :founder_id, :company_id)
  end
end
