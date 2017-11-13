module External::Concerns
  module Sortable
    extend ActiveSupport::Concern
    include CompetitorLists::Base::ClassSortable

    private

    def sorts
      SORTS
        .keys
        .reject { |k| !external_founder_signed_in? && k.in?(LOGGED_IN_SORTS) }
        .map { |x| [x, sort_params[x].to_i || 0] }
        .to_h
    end

    def sort_params
      params.permit(sort: SORTS.keys)[:sort] || {}
    end
  end
end
