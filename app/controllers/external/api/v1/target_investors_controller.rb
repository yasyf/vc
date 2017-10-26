class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable
  include External::Concerns::Pageable

  INCLUDES = [investor: [:entities, :university, :tweeter], founder: [:intro_requests, :entities]]

  before_action :authenticate_api_user!

  filter %w(investor.email investor.comments)

  def index
    current_external_founder.ensure_target_investors!
    targets = current_external_founder
      .target_investors
      .includes(*INCLUDES)
      .order(:stage, :id)
      .limit(limit)
      .offset(page * limit)
      .as_json
    render_censored  targets
  end

  def import
    investor = Investor.find(investor_params[:id])
    target = current_external_founder.create_target!(investor)
    render_censored target
  end

  def bulk_import
    if bulk_import_params[:headers].present?
      importer = Importers::External::TargetInvestors.new(session[:bulk_import_meta]['filename'], current_external_founder)
      targets = importer.import! bulk_import_params[:headers], session[:bulk_import_meta]['header_row']
      render_censored targets
    else
      parsed, meta = Importers::External::TargetInvestors.new(bulk_import_params[:csv_file], current_external_founder).parse!
      session[:bulk_import_meta] = meta
      render json: parsed
    end
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

  def destroy
    TargetInvestor.find(params[:id]).destroy!
    render json: {}
  end

  private

  def bulk_import_params
    params.permit(:csv_file, headers: {})
  end

  def investor_params
    params.require(:investor).permit(:id)
  end

  def ti_params
    params.require(:target_investor).permit(:firm_name, :first_name, :last_name, :stage, :role, :note, :email, :priority)
  end

  def ti_investor_params
    params.require(:target_investor).permit(investor: :note)
  end
  
  def ti_competitor_params
    params.require(:target_investor).permit(investor: {competitor: :note})
  end
end
