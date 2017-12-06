class ChangeGistIndexesToGin < ActiveRecord::Migration[5.1]
  def change
    remove_index :investors, name: :trgm_first_name_indx
    remove_index :investors, name: :trgm_last_name_indx
    remove_index :competitors, name: :trgm_name_indx

    create_trgm_index :investors, :first_name
    create_trgm_index :investors, :last_name
    create_trgm_index :investors, :location
    create_trgm_index :competitors, :name
    create_trgm_index :companies, :name
    create_trgm_index :founders, :city
  end

  private

  def create_trgm_index(table, column)
    reversible do |dir|
      dir.up { execute "CREATE INDEX #{table}_#{column}_gin_trgm_idx ON #{table} USING gin (#{column} gin_trgm_ops)" }
      dir.down { remove_index table, "#{table}_#{column}_gin_trgm_idx" }
    end
  end
end
