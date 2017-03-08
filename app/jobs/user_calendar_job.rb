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
    search_string = "#{event.summary || ''} #{event.description || ''}".downcase
    summary_words = (event.summary || '')
      .split(/[^\w]/)
      .select { |w| w.size > 3 && !IGNORES.include?(w.downcase) }
    description_words = (event.description || '')
      .split(/[^\w]/)
      .select { |w| w.size > 4 && w.first.upcase == w.first && !IGNORES.include?(w.downcase) }
    (summary_words + description_words).uniq.each do |word|
      company = Company.search(word).first
      return company if company.present? && search_string.include?(company.name.downcase)
    end
    nil
  end
end
