class AddIndustryToTargetInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :target_investors, :industry, :string
  end
end
