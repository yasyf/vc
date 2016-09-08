class ApplicationMonitorJob < ActiveJob::Base
  TRELLO_LINK_COUNT_THRESHOLD = 3

  queue_as :default

  def perform
    Team.for_each do |team|
      companies = team.lists.application.companies
      return if companies.blank?
      links = if companies.count <= TRELLO_LINK_COUNT_THRESHOLD
        companies.map { |company| "<#{company.trello_url}|#{company.name}>" }
      else
        companies.map(&:name)
      end
      message = "The following companies applied and are waiting to hear back from us!\n#{links.join(', ')}"
      team.notify! message
    end
  end
end
