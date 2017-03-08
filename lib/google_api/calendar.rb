require 'google/apis/calendar_v3'

module GoogleApi
  class Calendar < Base
    SCOPES = ['https://www.googleapis.com/auth/calendar']

    def initialize(user)
      @user = user
      @calendar = Google::Apis::CalendarV3::CalendarService.new
      @calendar.authorization = authorization
    end

    def events(cal_id: nil, since: DateTime.now, max_results: 1)
      cal_id ||= calendars.first&.id
      return [] unless cal_id.present?
      @calendar.list_events(
        cal_id,
        time_min: since.to_s,
        single_events: true,
        order_by: 'startTime',
        max_results: max_results
      ).items
    end

    def calendars
      @calendars ||= @calendar.list_calendar_lists.items
    rescue Signet::AuthorizationError
      []
    end
  end
end
