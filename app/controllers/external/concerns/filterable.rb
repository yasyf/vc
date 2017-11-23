module External::Concerns
  module Filterable
    extend ActiveSupport::Concern

    private

    def filter_params
      filters = params.permit(filters: [:industry, :location, :fund_type, :companies])[:filters]
      { filters: filters || {} }
    end

    def options_params
      options = params.permit(options: [:us_only, :related, :company_cities])[:options]
      { options: options.present? ? options.transform_values { |v| v.downcase == 'true' } : {} }
    end

    def search_params
      search = params.permit(search: [:first_name, :last_name, :firm_name])[:search]
      { search: search || {} }
    end

    def competitor_params
      filter_params.to_h.merge(options_params.to_h).merge(search_params.to_h)
    end

    def list_params
      params.permit(:list)
    end

    def filtered(opts = {})
      Competitor.filtered(current_external_founder, request, competitor_params, opts)
    end

    def filtered_count
      @filtered_count ||= Competitor.filtered_count(current_external_founder, request, competitor_params)
    end

    def filtered_suggestions
      {
        related: filter_params[:companies].present? && filtered_count == 0,
        company_cities: filter_params[:location].present? && filtered_count == 0,
      }.select { |_, v| v }.keys
    end

    def list_from_name
      @list ||= Competitor.list(current_external_founder, request, list_params[:list]) or not_found
    end

    def cached_list_from_name
      @list ||= Competitor.cached_list(current_external_founder, request, list_params[:list], { params[:key] => params[:value] }) or not_found
    end
  end
end
