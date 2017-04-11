class AddReportedInvalidToCalendarEvent < ActiveRecord::Migration[5.0]
  def change
    remove_column :calendar_events, :invalid
    add_column :calendar_events, :reported_invalid, :bool
  end
end
