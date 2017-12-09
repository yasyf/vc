class FoundersGmailSyncJob < ApplicationJob
  queue_as :default

  def perform
    Founder.active(1.year.ago).where.not(history_id: nil).pluck(:id).each do |id|
      FounderGmailSyncJob.perform_later id
    end
  end
end
