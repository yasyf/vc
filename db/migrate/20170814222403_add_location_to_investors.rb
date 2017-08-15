class AddLocationToInvestors < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :location, :string
  end
end
