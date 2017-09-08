class CreatePersonEntities < ActiveRecord::Migration[5.1]
  def change
    create_table :person_entities do |t|
      t.belongs_to :entity, foreign_key: true, null: false
      t.references :person, polymorphic: true, index: true, null: false

      t.timestamps
    end
  end
end
