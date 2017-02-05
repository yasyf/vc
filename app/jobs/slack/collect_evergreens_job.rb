class Slack::CollectEvergreensJob < Slack::BaseJob
  queue_as :default

  def perform
    Team.for_each do |team|
      history = client.channels_history channel: team.slack_channel, count: 1000
      evergreen = select_reactioned history.messages, "evergreen_tree"
      evergreen.each do |message|
        Knowledge.where(ts: message.ts).first_or_create! do |knowledge|
          knowledge.team = team
          knowledge.body = message.text
          knowledge.user = User.from_slack(message.user)
        end
      end
      Rails.logger.info "#{evergreen.count} imported for #{team.name}!"
    end
  end
end
