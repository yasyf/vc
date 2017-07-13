class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable

  before_action :authenticate_api_user!

  filter %w(investor.comments investor.competitor.comments)

  def index
    render_censored  current_external_founder.target_investors.includes(investor: :competitor)
  end

  def create
    target = TargetInvestor.create! investor_id: investor_params[:id], founder: current_external_founder, tier: investor_params[:tier]
    render_censored target
  end

  def update
    target = TargetInvestor.find(params[:id])
    if target_investor_stage_params.has_key?(:stage)
      target.change_stage!(target_investor_stage_params[:stage])
    end

    params = target_investor_params.to_h
    if params[:investor].present?
      if params[:investor][:competitor].present?
        target.investor.competitor.update! params[:investor].delete(:competitor)
      end
      target.investor.update! params.delete(:investor)
    end
    target.update! params

    render_censored target
  end

  private

  def investor_params
    params.require(:investor).permit(:id, :tier)
  end

  def target_investor_params
    params.require(:target_investor).permit(:tier, :funding_size, :industry, :note, investor: [:comments, {competitor: :comments}])
  end

  def target_investor_stage_params
    params.require(:target_investor).permit(:stage)
  end
end
