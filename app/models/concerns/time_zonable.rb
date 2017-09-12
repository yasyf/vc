module Concerns
  module TimeZonable
    extend ActiveSupport::Concern

    def utc_offset
      ActiveSupport::TimeZone[time_zone].utc_offset if time_zone.present?
    end
  end
end
