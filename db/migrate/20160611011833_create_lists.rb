class CreateLists < ActiveRecord::Migration[5.0]
  def change
    create_table :lists do |t|
      t.string :trello_id, null: false, blank: false, unique: true, index: true
      t.string :name, null: false, blank: false, unique: true, index: true
      t.float :pos, null: false, blank: false, unique: true

      t.timestamps null: false
    end
  end
end
