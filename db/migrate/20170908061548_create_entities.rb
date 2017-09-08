class CreateEntities < ActiveRecord::Migration[5.1]
  def change
    create_table :entities do |t|
      t.string :name, null: false
      t.string :category, null: false, default: 'OTHER'
      t.string :wiki
      t.string :mid

      t.timestamps

      t.index :name, unique: true
    end
  end
end
