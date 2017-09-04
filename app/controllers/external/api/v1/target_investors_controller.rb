class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable

  before_action :authenticate_api_user!

  filter %w(investor.email investor.comments investor.competitor.comments)

  def index
    if current_external_founder.target_investors.count == 0
      current_external_founder.target_investors.create! TargetInvestor::DUMMY_ATTRS
    end
    render_censored  current_external_founder.target_investors
                                       .includes(investor: [:notes, competitor: :notes])
                                       .order(:stage, :id)
  end

  def import
    investor = Investor.find(investor_params[:id])
    target = current_external_founder.create_target!(investor)
    render_censored target
  end

  def bulk_import
    render json: Importers::External::TargetInvestors.new(params[:file]).parse!
  end

  def create
    target = current_external_founder.target_investors.create! ti_params
    render_censored target
  end

  def update
    target = TargetInvestor.find(params[:id])

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

    render_censored target
  end

  private

  def investor_params
    params.require(:investor).permit(:id)
  end

  def ti_params
    params.require(:target_investor).permit(:firm_name, :first_name, :last_name, :stage, :role, :note, industry: [], fund_type: [])
  end

  def ti_investor_params
    params.require(:target_investor).permit(investor: :note)
  end
  
  def ti_competitor_params
    params.require(:target_investor).permit(investor: {competitor: :note})
  end
end
