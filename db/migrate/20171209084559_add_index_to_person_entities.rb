class AddIndexToPersonEntities < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE entities RESTART IDENTITY CASCADE'
    add_index :person_entities, [:entity_id, :person_type, :person_id], unique: true, name: 'index_person_entities_on_entity_and_person'
  end
end
