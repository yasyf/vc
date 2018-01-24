class AddHiddenToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :hidden, :boolean, null: false, default: false
  end
end
