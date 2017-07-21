class RemoveIndustryFromInvestorProfile < ActiveRecord::Migration[5.1]
  def change
    remove_column :investor_profiles, :industry, :string
  end
end
