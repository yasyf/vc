class FoundersGmailSyncJob < ApplicationJob
  queue_as :long_now

  def perform
    Founder.active(1.year.ago).where.not(history_id: nil).pluck(:id).each do |id|
      FounderGmailSyncJob.perform_later id
    end
  end
end
