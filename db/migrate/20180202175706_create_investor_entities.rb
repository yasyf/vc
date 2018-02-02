class CreateInvestorEntities < ActiveRecord::Migration[5.1]
  def change
    create_view :investor_entities, materialized: true
    add_index :investor_entities, :competitor_id
    add_index :investor_entities, :investor_id
    add_index :investor_entities, :entity_id
    add_index :investor_entities, :count, order: :desc
  end
end
