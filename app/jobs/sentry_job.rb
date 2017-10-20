class SentryJob < ApplicationJob
  queue_as :now

  def perform(event, dsn)
    Raven.configure { |config| config.dsn = dsn }
    Raven.send_event(event)
  end
end
