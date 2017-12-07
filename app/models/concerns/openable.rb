module Concerns
  module Openable
    extend ActiveSupport::Concern

    DEVICE_TYPES = %w(desktop mobile tablet other unknown)

    included do
      enum open_device_type: DEVICE_TYPES
    end

    def travel_status
      if open_country.blank?
        nil
      elsif open_country != 'US'
        :pleasure_traveling
      else
        investor.travel_status open_city
      end
    end
  end
end
