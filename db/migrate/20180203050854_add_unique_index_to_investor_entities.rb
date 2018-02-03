class AddUniqueIndexToInvestorEntities < ActiveRecord::Migration[5.1]
  def change
    add_index :investor_entities, [:investor_id, :entity_id], unique: true
  end
end
