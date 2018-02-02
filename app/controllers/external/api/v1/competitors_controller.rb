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
    paths = current_external_founder&.paths_to_domain(competitor.domain)
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
    render json: { suggestions: filtered_suggestions, **filtered_count_and_cols }
  end

  def locations
    render json: arr_to_options(Competitor.locations(params[:q]))
  end

  def lists
    render json: [] and return if Rails.env.development? && ENV['SKIP_LISTS']
    render json: Competitor.lists(current_external_founder, request).sort_by { |l| [l[:personalized] ? 0 : 1, rand] }
  end

  def update
    if external_founder_signed_in? && (stage = investor_params[:stage]).present?
      target = current_external_founder.target_investors.where(competitor: competitor).order(stage: :asc, updated_at: :desc).first!
      current_external_founder.investor_targeted! target.investor.id
      target.update! stage: stage
    end
    if competitor == current_external_investor&.competitor
      competitor.update!(verified: true) unless competitor.verified?

      if competitor_update_params.present?
        competitor.update! competitor_update_params
      end

      if competitor_industries.present?
        competitor.update! industry: competitor_industries.map { |i| i['value'] }
      end

      if competitor_locations.present?
        competitor.update! location: competitor_locations.map { |i| i['value'] }
      end

      if competitor_fund_types.present?
        competitor.update! fund_type: competitor_fund_types.map { |i| i['value'] }
      end

      if competitor_companies.present?
        ids = competitor_companies.to_a
        existing = competitor.companies.pluck(:id)
        (ids - existing).each do |id|
          Investment.where(company_id: id, competitor: competitor).first_or_create!
        end
        (existing - ids).each do |id|
          Investment.where(company_id: id, competitor: competitor).destroy_all
        end
      end
    end
    render json: {}
  end

  private

  def competitor_update_params
    params.require(:competitor).permit(:name, :domain, :photo, :twitter, :facebook, :al_id, :crunchbase_id, :description)
  end

  def competitor_industries
    params.require(:competitor).permit![:industries]
  end

  def competitor_companies
    params.require(:competitor).permit![:companies]
  end

  def competitor_locations
    params.require(:competitor).permit![:locations]
  end

  def competitor_fund_types
    params.require(:competitor).permit![:fund_types]
  end

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
