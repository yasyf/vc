class ApplicationMonitorJob < ActiveJob::Base
  include Concerns::Slackable

  queue_as :default

  def perform
    Team.for_each do |team|
      companies = team.lists.application.companies
      return if companies.blank?
      links = companies.map { |company| "<#{company.trello_url}|#{company.name}>" }
      message = "The following companies applied and are waiting to hear back from us!\n#{links.join(', ')}"
      slack_send! team.slack_channel, message, notify: true
    end
  end
end
