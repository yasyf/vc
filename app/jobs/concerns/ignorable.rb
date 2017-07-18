module Concerns
  module Ignorable
    extend ActiveSupport::Concern

    private

    def ignore_invalid
      yield
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.info e
    end
  end
end
