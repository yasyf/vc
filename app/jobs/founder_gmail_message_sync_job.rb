class FounderGmailMessageSyncJob < ApplicationJob
  queue_as :default

  def perform(founder_id, message_json)
    Message.new(Google::Apis::GmailV1::Message.from_json(message_json)).process!(Founder.find(founder_id))
  end
end
