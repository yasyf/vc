class ApplicationMonitorJob < ActiveJob::Base
  queue_as :default

  def perform
    Team.for_each do |team|
      companies = team.lists.application.companies
      next if companies.blank?
      links = companies.map { |company| "<#{company.trello_url}|#{company.name}>" }
      message = "The following companies applied and are waiting to hear back from us!" +
        " If you're already talking with one, please move it to the 'Allocated Point Partner' column." +
        "\n#{links.join(', ')}"
      team.notify! message
    end
  end
end
