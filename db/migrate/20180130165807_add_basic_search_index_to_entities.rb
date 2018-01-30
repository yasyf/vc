class AddBasicSearchIndexToEntities < ActiveRecord::Migration[5.1]
  def change
    execute "CREATE INDEX ON entities USING gin(to_tsvector('english', name));"
  end
end
