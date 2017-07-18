module Concerns
  module Ignorable
    extend ActiveSupport::Concern

    def self.unique_errors
      [ActiveRecord::RecordNotUnique, PG::UniqueViolation]
    end

    def self.invalid_errors
      [ActiveRecord::RecordInvalid]
    end

    private

    def ignore_record_errors
      ignore(self.class.unique_errors + self.class.invalid_errors, &block)
    end

    def ignore_unique(&block)
      ignore(self.class.unique_errors, &block)
    end

    def ignore_invalid(&block)
      ignore(self.class.invalid_errors, &block)
    end

    def ignore(types)
      yield
    rescue *Array.wrap(types) => e
      Rails.logger.info e
    end
  end
end
