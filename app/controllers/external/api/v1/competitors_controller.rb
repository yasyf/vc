class External::Api::V1::CompetitorsController < External::Api::V1::ApiV1Controller
  include External::Concerns::Censorable
  include External::Concerns::Filterable
  include External::ApplicationHelper

  MAX_LIMIT = 20

  before_action :authenticate_api_user!

  filter %w(comments)

  def show
    render_censored  Competitor.find(params[:id])
  end

  def filter
    competitors = filtered.limit(limit).offset(page * limit)
    render json: competitors
  end

  def filter_count
    render json: { count: filtered_count }
  end

  def locations
    render json: arr_to_options(Competitor.locations(params[:q]))
  end

  def lists
    render json: Competitor.lists(current_external_founder)
  end

  private

  def page
    (params[:page] || 0).to_i
  end

  def limit
    [(params[:limit] || MAX_LIMIT).to_i, MAX_LIMIT].min
  end
end
