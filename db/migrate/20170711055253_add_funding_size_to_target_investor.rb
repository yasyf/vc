class AddFundingSizeToTargetInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :target_investors, :funding_size, :integer
  end
end
