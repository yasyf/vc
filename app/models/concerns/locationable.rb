module Concerns
  module Locationable
    extend ActiveSupport::Concern

    included do
      @location_attr = :location
    end

    class_methods do
      def locationable_with(attr)
        @location_attr = attr
      end

      def locations(query, limit = 5)
        scope = where.not(@location_attr => nil).select("#{@location_attr}, count(id) AS cnt").group(@location_attr)
        scope = scope.fuzzy_search(@location_attr => query) if query.present?
        scope = scope.order('cnt DESC').limit(limit)
        connection.select_values scope.to_sql
      end
    end
  end
end
