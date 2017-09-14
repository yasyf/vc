class AddFieldsToTweet < ActiveRecord::Migration[5.1]
  def change
    add_column :tweets, :tweeted_at, :datetime
    add_column :tweets, :text, :string
  end
end
