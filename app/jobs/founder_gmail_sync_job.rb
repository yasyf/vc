class FounderGmailSyncJob < ApplicationJob
  queue_as :long_now

  def perform(founder_id)
    GoogleApi::Gmail.new(Founder.find(founder_id)).sync!
  end
end
