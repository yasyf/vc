class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def index
    render json: current_external_founder.target_investors.includes(investor: :competitor)
  end

  def create
    target = TargetInvestor.create! investor_id: investor_params[:id], founder: current_external_founder
    render json: target
  end

  def update
    return head :bad_request unless target_investor_params.has_key?(:stage)
    target = TargetInvestor.find(params[:id])
    target.change_stage!(target_investor_params[:stage])
    head :ok
  end

  private

  def investor_params
    params.require(:investor).permit(:id)
  end

  def target_investor_params
    params.require(:target_investor).permit(:id, :stage, :tier, :last_response)
  end
end
