class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.belongs_to :investor, foreign_key: true, null: false
      t.string :url, null: false
      t.string :title, null: false
      t.datetime :published_at, null: false

      t.timestamps
    end
  end
end
