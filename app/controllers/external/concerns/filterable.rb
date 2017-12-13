module External::Concerns
  module Filterable
    extend ActiveSupport::Concern

    private

    def filter_params
      filters = params.permit(filters: [:industry, :location, :fund_type, :companies])[:filters]
      filters = (filters || {}).merge(JSON.parse(cookies[:filters])) if cookies[:filters].present?
      { filters: filters || {} }
    end

    def options_params
      options = params.permit(options: [:us_only, :related, :company_cities])[:options]
      { options: options.present? ? options.transform_values { |v| v.is_a?(String) ? v.downcase == 'true' : v } : {} }
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

    def filtered_results(opts = {})
      Competitor.filtered(current_external_founder, request, competitor_params, opts)
    end

    def filtered_count
      Competitor.filtered_count(current_external_founder, request, competitor_params)
    end

    def filtered_suggestions
      @filtered_suggestions ||= begin
        original = params[:options].dup

        if filtered_count == 0
          params[:options] = (params[:options] || {}).merge(
            related: filter_params[:filters][:companies].present?,
            company_cities: filter_params[:filters][:location].present?
          )
        elsif params[:options].present?
          params[:options].except(:us_only).select { |_, v| v }.keys.each do |k|
            params[:options][k] = false
            params[:options][k] = true if filtered_count == 0
          end
        end

        suggestions = params[:options].dup
        params[:options] = original

        suggestions
      end
    end

    def apply_suggestions!
      params[:options] = filtered_suggestions
    end

    def list_from_name
      @list ||= if params[:key].present? && params[:value].present?
        Competitor.param_list(current_external_founder, request, list_params[:list], { params[:key] => params[:value] })
      else
        Competitor.list(current_external_founder, request, list_params[:list])
      end or not_found
    end
  end
end
