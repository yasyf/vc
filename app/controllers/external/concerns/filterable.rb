module External::Concerns
  module Filterable
    extend ActiveSupport::Concern

    private

    def filter_params
      filters = params.permit(filters: [:industry, :location, :fund_type, :companies])[:filters]
      filters = (filters || {}).merge(JSON.parse(cookies[:filters]).symbolize_keys) if @merge_cookie_filters && cookies[:filters].present?
      { filters: filters || {} }
    end

    def options_params
      options = params.permit(options: [:us_only, :industry_or, :related, :company_cities])[:options]
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
        params[:options] ||= {}

        if filtered_count != 0
          options_params.except(:us_only).select { |_, v| v }.keys.each do |k|
            params[:options][k] = false
            params[:options][k] = true if filtered_count == 0
          end
        end

        if filter_params[:filters][:location].present? && filtered_count == 0
          if options_params[:company_cities]
            params[:options][:company_cities] = false
            if filtered_count == 0
              params[:options][:company_cities] = true
            end
          else
            params[:options][:company_cities] = true
            if filtered_count == 0
              params[:options][:company_cities] = false
            end
          end
        end

        if filter_params[:filters][:companies].present? && !options_params[:related] && filtered_count <= 1
          params[:options][:related] = true
        end

        if filter_params[:filters][:industry].present? && !options_params[:industry_or] && filtered_count == 0
          params[:options][:industry_or] = true
        end

        suggestions = options_params.dup
        params[:options] = original

        suggestions[:options]
      end
    end

    def apply_suggestions!
      params[:options] = filtered_suggestions
    end

    def merge_cookie_filters!
      @merge_cookie_filters = true
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
