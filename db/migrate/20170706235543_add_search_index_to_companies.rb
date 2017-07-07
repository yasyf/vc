class AddSearchIndexToCompanies < ActiveRecord::Migration[5.1]
  def up
    execute "create index on companies using gin(to_tsvector('english', name));"
  end

  def down
    remove_index :companies, :companies_to_tsvector_idx
  end
end
