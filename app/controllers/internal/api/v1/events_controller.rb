class Internal::Api::V1::EventsController < Internal::Api::V1::ApiV1Controller
  before_action :authenticate_api_user!

  def show
    render json: { event: event }
  end

  def update
    event.add_notes! params[:notes]
    render json: { link: event.notes_doc_link }
  end

  def invalidate
    event.update! invalid: true
    head :ok
  end

  private

  def event
    @event ||= CalendarEvent.find(params[:id])
  end
end
