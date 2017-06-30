class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :trello_id, null: false
      t.belongs_to :list, foreign_key: true, null: false
      t.belongs_to :company, foreign_key: true, null: false

      t.index :trello_id, unique: true

      t.timestamps
    end
  end
end
