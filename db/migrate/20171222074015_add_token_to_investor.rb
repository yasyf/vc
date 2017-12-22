class AddTokenToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :token, :string
    add_index :investors, :token, unique: true
  end
end
