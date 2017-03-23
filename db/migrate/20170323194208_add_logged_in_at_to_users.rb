class AddLoggedInAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :logged_in_at, :datetime, null: false, default: 3.weeks.ago
  end
end
