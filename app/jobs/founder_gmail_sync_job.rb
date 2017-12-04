class FounderGmailSyncJob < ApplicationJob
  queue_as :low

  def perform(founder_id)
    GoogleApi::Gmail.new(Founder.find(founder_id)).sync!
  end
end
