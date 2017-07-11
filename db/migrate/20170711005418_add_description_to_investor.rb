class AddDescriptionToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :description, :text
  end
end
