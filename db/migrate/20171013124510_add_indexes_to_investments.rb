class AddIndexesToInvestments < ActiveRecord::Migration[5.1]
  def change
    add_index :investments, :funded_at
  end
end
