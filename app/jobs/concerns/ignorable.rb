module Concerns
  module Ignorable
    extend ActiveSupport::Concern

    private

    def unique_errors
      [ActiveRecord::RecordNotUnique, PG::UniqueViolation]
    end

    def invalid_errors
      [ActiveRecord::RecordInvalid]
    end

    def ignore_record_errors
      ignore(unique_errors + invalid_errors, &block)
    end

    def ignore_unique(&block)
      ignore(unique_errors, &block)
    end

    def ignore_invalid(&block)
      ignore(invalid_errors, &block)
    end

    def ignore(types)
      yield
    rescue *Array.wrap(types) => e
      Rails.logger.info e
    end
  end
end
