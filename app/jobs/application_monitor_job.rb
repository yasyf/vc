class ApplicationMonitorJob < ActiveJob::Base
  queue_as :default

  def perform
    Team.for_each do |team|
      companies = team.lists.application.companies
      next if companies.blank?
      companies.each do |company|
        next unless company.users.present?
        company.users.each do |user|
          message = "It looks like you're a point partner for #{company.name}, but the card is still" +
            " in the #{team.lists.application.name} column. Please either move it to the #{team.lists.allocated.name}" +
            " column, or remove yourself from the card. Thanks!"
          user.send! message
        end
      end
      links = companies.map { |company| "<#{company.trello_url}|#{company.name}>" }
      message = "The following companies applied and are waiting to hear back from us!" +
        " If you're already talking with one, please move it to the 'Allocated Point Partner' column." +
        "\n#{links.join(', ')}"
      team.notify! message, all: false
    end
  end
end
