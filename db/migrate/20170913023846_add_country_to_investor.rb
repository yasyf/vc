class AddCountryToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :country, :string
  end
end
