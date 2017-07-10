class AddLoggedInAtToFounders < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :logged_in_at, :datetime
  end
end
