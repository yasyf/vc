class CardMonitorJob < ActiveJob::Base
  queue_as :default

  def perform
    Team.for_each do |team|
      companies = Company.where(list: List.funnel(team)).map do |company|
        move_event = LoggedEvent.for(company, :company_list_changed)
        if move_event && move_event.updated_at < 1.week.ago
          last_date = (move_event.data.last['date'] || move_event.updated_at).to_date
          move_event.touch
          users = company.users.map { |user| "<@#{user.slack_id}>" }.join(', ')
          "#{users}: <#{company.trello_url}|#{company.name}> (#{company.list.name}, #{last_date.to_s(:long)})"
        end
      end.compact.join("\n")

      if companies.present?
        message = "The following companies have been stuck in the same stage of the pipeline for over a week!\n#{companies}"
        team.notify! message, all: false
      end
    end
  end
end
