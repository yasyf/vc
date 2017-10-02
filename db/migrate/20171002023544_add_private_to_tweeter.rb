class AddPrivateToTweeter < ActiveRecord::Migration[5.1]
  def change
    add_column :tweeters, :private, :boolean, default: false, null: false
  end
end
