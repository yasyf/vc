class AddFeaturedToPersonEntity < ActiveRecord::Migration[5.1]
  def change
    add_column :person_entities, :featured, :boolean, default: false
  end
end
