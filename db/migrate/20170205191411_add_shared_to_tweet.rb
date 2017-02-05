class AddSharedToTweet < ActiveRecord::Migration[5.0]
  def change
    add_column :tweets, :shared, :boolean, null: false, default: false
  end
end
