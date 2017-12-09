class FounderGmailMessageSyncJob < ApplicationJob
  queue_as :default

  def perform(user, message_json)
    Message.new(Google::Apis::GmailV1::Message.from_json(message_json)).process!(user)
  end
end
