class AddIndustryToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :industry, :string, array: true
    add_index :investors, :industry, using: 'gin'
  end
end
