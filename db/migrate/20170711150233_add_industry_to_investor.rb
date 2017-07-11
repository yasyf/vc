class AddIndustryToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :industry, :string
  end
end
