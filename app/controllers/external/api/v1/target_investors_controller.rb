class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable

  before_action :authenticate_api_user!

  filter %w(investor.comments investor.competitor.comments)

  def index
    render_censored  current_external_founder.target_investors
                                       .includes(investor: [:notes, competitor: :notes])
                                       .order(:stage)
  end

  def create
    target = TargetInvestor.create! investor_id: investor_params[:id], founder: current_external_founder, tier: 1
    render_censored target
  end

  def update
    target = TargetInvestor.find(params[:id])

    if ti_stage_params.present?
      target.change_stage!(ti_stage_params[:stage])
    end

    if ti_investor_params.present? && ti_investor_params[:investor].present?
      note = target.investor.notes.first_or_initialize(founder: current_external_founder)
      note.body = ti_investor_params[:investor][:note]
      note.save!
    end

    if ti_competitor_params.present? && ti_competitor_params[:investor].present? && ti_competitor_params[:investor][:competitor].present?
      note = target.investor.competitor.notes.first_or_initialize(founder: current_external_founder)
      note.body = ti_competitor_params[:investor][:competitor][:note]
      note.save!
    end

    if ti_params.present?
      target.update! ti_params
    end

    if ti_investor_override_params.present?
      target.update! ti_investor_override_params[:investor]
    end

    if ti_competitor_override_params.present? && ti_competitor_override_params[:investor].present?
      target.update! ti_competitor_override_params[:investor][:competitor]
    end

    render_censored target
  end

  private

  def investor_params
    params.require(:investor).permit(:id, :tier)
  end

  def ti_params
    params.require(:target_investor).permit(:tier, :funding_size, :industry, :note)
  end

  def ti_stage_params
    params.require(:target_investor).permit(:stage)
  end

  def ti_investor_override_params
    params.require(:target_investor).permit(investor: [:industry, :funding_size])
  end

  def ti_competitor_override_params
    params.require(:target_investor).permit(investor: {competitor: [:industry, :funding_size]})
  end

  def ti_investor_params
    params.require(:target_investor).permit(investor: :note)
  end
  
  def ti_competitor_params
    params.require(:target_investor).permit(investor: {competitor: :note})
  end
end
