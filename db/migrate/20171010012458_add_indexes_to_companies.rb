class AddIndexesToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_index :companies, :al_id, unique: true
    reversible do |dir|
      dir.up { execute 'CREATE INDEX trgm_name_indx ON competitors USING gist (name gist_trgm_ops);' }
      dir.down { remove_index :companies, :trgm_name_indx }
    end
  end
end