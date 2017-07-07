class AddSearchIndexToInvestors < ActiveRecord::Migration[5.1]
  def up
    execute '
      CREATE INDEX trgm_first_name_indx ON investors USING gist (first_name gist_trgm_ops);
      CREATE INDEX trgm_last_name_indx ON investors USING gist (last_name gist_trgm_ops);
    '
  end

  def down
    remove_index :investors, :trgm_first_name_indx
    remove_index :investors, :trgm_last_name_indx
  end
end
