class ApplicationMonitorJob < ActiveJob::Base
  include Concerns::Slackable

  queue_as :default

  def perform
    companies = List.application.companies
    return if companies.blank?
    links = companies.map { |company| "<#{company.trello_url}|#{company.name}>" }
    message = "The following companies applied and are waiting to hear back from us!\n#{links.join(', ')}"
    slack_send! ENV['SLACK_CHANNEL'], message, notify: true
  end
end
