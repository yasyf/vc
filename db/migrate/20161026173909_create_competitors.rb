class CreateCompetitors < ActiveRecord::Migration[5.0]
  def change
    create_table :competitors do |t|
      t.string :name
      t.string :crunchbase_id

      t.timestamps
    end
    add_index :competitors, :name, unique: true
    add_index :competitors, :crunchbase_id, unique: true
    Competitor::COMPETITORS.keys.each { |name| Competitor.create_from_name!(name) }
  end
end
