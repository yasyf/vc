class SentryJob < ApplicationJob
  queue_as :now

  def perform(event)
    Raven.send_event(event)
  end
end
