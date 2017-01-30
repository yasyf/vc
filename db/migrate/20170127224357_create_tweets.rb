class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.bigint :twitter_id

      t.timestamps
    end
  end
end
