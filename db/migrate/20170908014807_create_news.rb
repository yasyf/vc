class CreateNews < ActiveRecord::Migration[5.1]
  def change
    create_table :news do |t|
      t.belongs_to :investor, foreign_key: true, null: false
      t.belongs_to :company, foreign_key: true
      t.string :url, null: false
      t.string :title, null: false
      t.text :description, null: false

      t.index [:url, :investor_id], unique: true

      t.timestamps
    end
  end
end
