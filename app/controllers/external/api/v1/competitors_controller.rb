class External::Api::V1::CompetitorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable
  include External::Concerns::Filterable
  include External::Concerns::Pageable
  include External::Concerns::Sortable
  include External::ApplicationHelper

  def show
    render_censored  competitor
  end

  def intro_path_counts
    render json: { intro_paths: [] } and return unless external_founder_signed_in?
    paths = Competitor
      .where(id: params[:ids].split(','))
      .where.not(domain: nil)
      .where.not(domain: current_external_founder.domain)
      .map { |c| [c.id, current_external_founder.count_paths_to_domain(c.domain)] }
      .to_h
    render json: { intro_paths: paths }
  end

  def intro_paths
    paths = current_external_founder.paths_to_domain(competitor.domain)
    render json: { paths: paths }
  end

  def filter
    apply_suggestions! if apply_suggestions?
    competitors = filtered_results(sort: sorts, limit: limit, offset: page * limit, meta: true)
    render json: competitors
  end

  def list
    competitors = list_from_name.results(limit: limit, offset: page * limit, meta: true)
    render json: competitors
  end

  def filter_count
    apply_suggestions! if apply_suggestions?
    render json: { count: filtered_count, suggestions: filtered_suggestions }
  end

  def locations
    render json: arr_to_options(Competitor.locations(params[:q]))
  end

  def lists
    render json: Competitor.lists(current_external_founder, request).sort_by { |l| [l[:personalized] ? 0 : 1, rand] }
  end

  def update
    if external_founder_signed_in? && (stage = investor_params[:stage]).present?
      target = current_external_founder.target_investors.where(competitor: competitor).order(stage: :asc, updated_at: :desc).first!
      current_external_founder.investor_targeted! target.investor.id
      target.update! stage: stage
    end
    render json: {}
  end

  private

  def competitor
    @competitor ||= Competitor.find(params[:id])
  end

  def investor_params
    params.require(:competitor).permit(:stage)
  end

  def apply_suggestions?
    params[:apply_suggestions] == 'true'
  end
end
