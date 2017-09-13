class AddAmountAndFundingTypeAndSeriesToInvestment < ActiveRecord::Migration[5.1]
  def change
    add_column :investments, :funding_type, :string
    add_column :investments, :series, :string
    add_column :investments, :round_size, :bigint
  end
end
