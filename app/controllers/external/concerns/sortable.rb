module External::Concerns
  module Sortable
    extend ActiveSupport::Concern

    private

    def sorts
      CompetitorLists::Base::ClassSortable::SORTS.keys.map { |x| [x, sort_params[x].to_i || 0] }.to_h
    end

    def sort_params
      params.permit(sort: CompetitorLists::Base::ClassSortable::SORTS.keys)[:sort] || {}
    end
  end
end
