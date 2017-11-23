class External::Api::V1::CompetitorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable
  include External::Concerns::Filterable
  include External::Concerns::Pageable
  include External::Concerns::Sortable
  include External::ApplicationHelper

  def show
    render_censored  Competitor.find(params[:id])
  end

  def filter
    competitors = filtered(sort: sorts, limit: limit, offset: page * limit, meta: true)
    render json: competitors
  end

  def list
    competitors = list_from_name.results(limit: limit, offset: page * limit, meta: true)
    render json: { competitors: competitors, columns: list_from_name.meta_cols }
  end

  def filter_count
    render json: { count: filtered_count, suggestions: filtered_suggestions }
  end

  def locations
    render json: arr_to_options(Competitor.locations(params[:q]))
  end

  def lists
    render json: Competitor.lists(current_external_founder, request).shuffle
  end
end
