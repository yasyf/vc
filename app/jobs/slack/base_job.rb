class Slack::BaseJob < ApplicationJob
  def select_reactioned(items, reaction)
    items.select do |item|
      item.reactions.present? && item.reactions.map(&:name).include?(reaction)
    end
  end

  def client
    @client ||= Slack::Web::Client.new(token: ENV['SLACK_ADMIN_TOKEN'])
  end
end
