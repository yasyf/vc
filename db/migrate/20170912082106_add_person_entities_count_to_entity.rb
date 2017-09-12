class AddPersonEntitiesCountToEntity < ActiveRecord::Migration[5.1]
  def change
    add_column :entities, :person_entities_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE entities
            SET person_entities_count = (SELECT count(*) 
                                          FROM person_entities
                                          WHERE person_entities.entity_id = entities.id)
        SQL
      end
    end
  end
end
