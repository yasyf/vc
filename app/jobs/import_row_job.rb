class ImportRowJob < ApplicationJob
  queue_as :default

  def perform(name, parsed)
    klass = name.constantize
    unless klass.process!(parsed) == false
      Rails.logger.info parsed
      klass.import! parsed
    end
  end
end
