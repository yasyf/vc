class AddIndustryToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :industry, :string, array: true
    add_index :companies, :industry, using: 'gin'
  end
end
