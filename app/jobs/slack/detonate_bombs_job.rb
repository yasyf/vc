class Slack::DetonateBombsJob < Slack::BaseJob
  queue_as :default

  def perform(name)
    team = Team.send(name)

    history = client.channels_history channel: team.slack_channel, count: 1000
    bombed = select_reactioned history.messages, "bomb"
    responses = Workers.map(bombed) do |message|
      client.chat_delete ts: message.ts, channel: team.slack_channel, as_user: true
    end
    deleted = responses.select { |m| m.ok }
    Rails.logger.info "#{bombed.count} messages found, #{deleted.count} messages deleted!"

    file_list = client.files_list channel: team.slack_channel, count: 1000
    bombed = select_reactioned file_list.files, "bomb"
    responses = Workers.map(bombed) do |file|
      client.files_delete file: file.id
    end
    deleted = responses.select { |m| m.ok }
    Rails.logger.info "#{bombed.count} files found, #{deleted.count} files deleted!"
  end
end
