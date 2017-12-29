class AddMissingIndexes < ActiveRecord::Migration[5.1]
  def up
    execute "CREATE INDEX investors_to_tsvector_fname ON investors USING gin(to_tsvector('english', first_name));"
    execute "CREATE INDEX investors_to_tsvector_lname ON investors USING gin(to_tsvector('english', last_name));"
    add_index :competitors, :al_id
    add_index :investors, :al_id
  end

  def down
    remove_index :investors, name: :investors_to_tsvector_fname
    remove_index :investors, name: :investors_to_tsvector_lname
    remove_index :investors, :fund_type
    remove_index :competitors, :al_id
    remove_index :investors, :al_id
  end
end
