class External::Api::V1::CompetitorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable
  include External::Concerns::Filterable
  include External::Concerns::Pageable
  include External::Concerns::Sortable
  include External::ApplicationHelper

  def show
    render_censored  Competitor.find(params[:id])
  end

  def intro_paths
    render json: { intro_paths: [] } and return unless external_founder_signed_in?
    paths = Competitor
      .where(id: params[:ids].split(','))
      .where.not(domain: nil)
      .where.not(domain: current_external_founder.domain)
      .map { |c| [c.id, current_external_founder.path_to_domain(c.domain)] }
      .to_h
    render json: { intro_paths: paths }
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

  private

  def apply_suggestions?
    params[:apply_suggestions] == 'true'
  end
end
