module Concerns
  module Ignorable
    extend ActiveSupport::Concern

    TRIES = 2

    private

    def unique_errors
      [ActiveRecord::RecordNotUnique, PG::UniqueViolation]
    end

    def invalid_errors
      [ActiveRecord::RecordInvalid]
    end

    def retry_record_errors(&block)
      retry_(unique_errors + invalid_errors, &block)
    end

    def ignore_record_errors(&block)
      ignore(unique_errors + invalid_errors, &block)
    end

    def ignore_unique(&block)
      ignore(unique_errors, &block)
    end

    def retry_unique(&block)
      retry_(unique_errors, &block)
    end

    def ignore_invalid(&block)
      ignore(invalid_errors, &block)
    end

   def retry_invalid(&block)
     retry_(invalid_errors, &block)
    end

    def ignore(types)
      yield
    rescue *Array.wrap(types) => e
      Rails.logger.error e
      nil
    end

    def retry_(types)
      remaining ||= TRIES
      yield
    rescue *Array.wrap(types) => e
      retry unless (remaining -= 1).zero?
      Rails.logger.error e
      nil
    end
  end
end
