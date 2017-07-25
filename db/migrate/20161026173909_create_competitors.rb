class CreateCompetitors < ActiveRecord::Migration[5.0]
  def change
    create_table :competitors do |t|
      t.string :name
      t.string :crunchbase_id

      t.timestamps
    end
    add_index :competitors, :name, unique: true
    add_index :competitors, :crunchbase_id, unique: true
  end
end
