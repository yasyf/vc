module External::Concerns
  module Pageable
    extend ActiveSupport::Concern

    MAX_LIMIT = 20

    private

    def page
      (params[:page] || 0).to_i
    end

    def limit
      [(params[:limit] || MAX_LIMIT).to_i, MAX_LIMIT].min
    end
  end
end
