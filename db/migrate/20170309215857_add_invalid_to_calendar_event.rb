class AddInvalidToCalendarEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :calendar_events, :invalid, :boolean, null: false, default: false
  end
end
