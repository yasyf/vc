class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :trello_id, null: false, blank: false, unique: true
      t.string :name, null: false, blank: false
      t.float :pos, null: false, blank: false, unique: true

      t.timestamps null: false
    end
  end
end
