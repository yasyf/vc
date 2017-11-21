class External::Api::V1::TargetInvestorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable
  include External::Concerns::Pageable
  include External::Concerns::Sortable

  INCLUDES = [investor: [:entities, :university, :tweeter, :competitor], founder: [:intro_requests, :entities]]

  before_action :authenticate_api_user!

  filter %w(investor.email investor.comments)

  def index
    targets = current_external_founder
      .target_investors
      .includes(*INCLUDES)
      .order(sort_params.present? ? order_sql_from_sort(sorts) : [updated_at: :desc])
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

  def bulk_poll
    render json: import_task
  end

  def bulk_import
    if bulk_import_params[:id].present?
      import_task.update! headers: bulk_import_params[:headers]
      import_task.enqueue_import!
      render json: import_task
    else
      import_task = current_external_founder.import_tasks.create!
      import_task.file = bulk_import_params[:file]
      import_task.enqueue_preview!
      render json: import_task
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

  def import_task
    @import_task ||= ImportTask.find(params[:id]).tap do |import_task|
      not_found unless import_task.founder == current_external_founder
    end
  end

  def bulk_import_params
    params.permit(:file, :id, headers: {})
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
