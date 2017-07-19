class CardMonitorJob < ActiveJob::Base
  queue_as :default

  def perform
    Team.for_each do |team|
      Card.where(list: List.funnel(team)).map(&:company).map do |company|
        move_event = LoggedEvent.for(company, :company_list_changed)
        if move_event && move_event.updated_at < 1.week.ago
          last_date = (move_event.data.last['date'] || move_event.updated_at).to_date
          move_event.touch
          message = "<#{company.trello_url}|#{company.name}> has been stuck in #{company.list.name} since #{last_date.to_s(:long)}!"
          company.users.each do |user|
            user.send! message
          end
        end
      end
    end
  end
end
