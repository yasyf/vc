class FounderGmailBackfillJob < ApplicationJob
  queue_as :long

  def perform(founder_id, oldest, newest)
    GoogleApi::Gmail.new(Founder.find(founder_id)).backfill!(oldest, newest)
  end
end
