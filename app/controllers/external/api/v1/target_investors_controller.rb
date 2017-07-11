class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def index
    render json: current_external_founder.target_investors.includes(investor: :competitor)
  end

  def create
    target = TargetInvestor.create! investor_id: investor_params[:id], founder: current_external_founder, tier: investor_params[:tier]
    render json: target
  end

  def update
    target = TargetInvestor.find(params[:id])
    if target_investor_stage_params.has_key?(:stage)
      target.change_stage!(target_investor_stage_params[:stage])
    end
    target.update! target_investor_params
    render json: target
  end

  private

  def investor_params
    params.require(:investor).permit(:id, :tier)
  end

  def target_investor_params
    params.require(:target_investor).permit(:tier, :funding_size)
  end

  def target_investor_stage_params
    params.require(:target_investor).permit(:stage)
  end
end
