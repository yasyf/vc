class AddDataToLoggedEvent < ActiveRecord::Migration[5.0]
  def change
    LoggedEvent.delete_all
    add_column :logged_events, :data, :json, null: false, default: []
  end
end
