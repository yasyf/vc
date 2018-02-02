class AddCountToPersonEntity < ActiveRecord::Migration[5.1]
  def change
    add_column :person_entities, :count, :integer, null: false, default: 1
  end
end
