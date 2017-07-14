class AddFundingSizeToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :funding_size, :integer
  end
end
