class UserCalendarJob < ActiveJob::Base
  include Concerns::Slackable

  queue_as :default

  def perform
    User.all.each do |user|
      event = GoogleApi::Calendar.new(user).events.first
      next unless event.present? && event.start.date_time < 1.day.from_now
      next unless (company = find_company(event))
      calevent = CalendarEvent.where(id: event.id).first_or_create! do |ce|
        ce.user = user
        ce.company = company
      end
      LoggedEvent.do_once(calevent, :request_notes) do
        response = slack_client.mpim_open users: [ENV['DRFBOT_USER'], user.slack_id].join(',')
        slack_send! response.group.id, "<@#{ENV['DRFBOT_USER']}>: event #{calevent.id}"
      end
    end
  end

  private

  def find_company(event)
    event.summary.split(/[^\w]/).select { |w| w.size > 0 && w.first.upcase == w.first }.each do |word|
      company = Company.search(word).first
      return company if company.present?
    end
    nil
  end
end
