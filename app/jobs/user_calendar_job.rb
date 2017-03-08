class UserCalendarJob < ActiveJob::Base
  include Concerns::Slackable

  IGNORES = %w(dorm room fund)

  queue_as :default

  def perform
    User.all.each do |user|
      event = GoogleApi::Calendar.new(user).events.first
      next unless event.present? && event.start.date_time < 6.hours.from_now && event.recurring_event_id.blank?
      next unless (company = find_company(event))
      calevent = CalendarEvent.where(id: event.id).first_or_create! do |ce|
        ce.user = user
        ce.company = company
      end
      LoggedEvent.do_once(calevent, :request_notes) do
        slack_send! ENV['DRFBOT_USER'], "calendar_event #{user.slack_id} #{calevent.id}"
      end
    end
  end

  private

  def find_company(event)
    words = event.summary
      .split(/[^\w]/)
      .select { |w| w.size > 0 && w.first.upcase == w.first && !IGNORES.include?(w.downcase) }
    words.each do |word|
      company = Company.search(word).first
      return company if company.present?
    end
    nil
  end
end
