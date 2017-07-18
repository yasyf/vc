class AddIndustryToCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :competitors, :industry, :string, array: true
    add_index :competitors, :industry, using: 'gin'
  end
end
