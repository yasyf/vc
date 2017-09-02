class AddOptedInToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :opted_in, :boolean, null: true
  end
end
