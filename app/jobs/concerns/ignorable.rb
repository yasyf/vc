module Concerns
  module Ignorable
    extend ActiveSupport::Concern

    private

    def ignore_unique(&block)
      ignore([ActiveRecord::RecordNotUnique, PG::UniqueViolation], &block)
    end

    def ignore_invalid(&block)
      ignore(ActiveRecord::RecordInvalid, &block)
    end

    def ignore(types)
      yield
    rescue *Array.wrap(types) => e
      Rails.logger.info e
    end
  end
end
