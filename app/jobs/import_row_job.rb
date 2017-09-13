class ImportRowJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :default

  def perform(name, parsed)
    klass = name.constantize
    unless klass.process!(parsed) == false
      Rails.logger.info parsed
      ignore_record_errors { klass.import! parsed }
    end
  end
end
