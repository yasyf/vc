class DropInvestorProfiles < ActiveRecord::Migration[5.1]
  def change
    drop_table :investor_profiles
  end
end
