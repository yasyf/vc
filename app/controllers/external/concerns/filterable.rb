module External::Concerns
  module Filterable
    extend ActiveSupport::Concern

    private

    def filter_params
      params.permit(:industry, :location, :fund_type, :companies, :search)
    end

    def options_params
      params.permit(:us_only, :related, :company_cities).transform_values { |v| v.downcase == 'true' }
    end

    def competitor_params
      filter_params.to_h.merge(options_params.to_h)
    end

    def list_params
      params.permit(:list)
    end

    def filtered(opts = {})
      Competitor.filtered(competitor_params, opts)
    end

    def filtered_count
      Competitor.filtered_count(competitor_params)
    end

    def list_from_name
      @list ||= Competitor.list(current_external_founder, request, list_params[:list]) or not_found
    end
  end
end
