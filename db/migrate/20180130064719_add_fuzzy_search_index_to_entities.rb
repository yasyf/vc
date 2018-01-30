class AddFuzzySearchIndexToEntities < ActiveRecord::Migration[5.1]
  def change
    execute 'CREATE INDEX trgm_name_indx_on_entities ON entities USING gist (name gist_trgm_ops);'
  end
end
