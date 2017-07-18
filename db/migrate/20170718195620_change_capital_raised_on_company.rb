class ChangeCapitalRaisedOnCompany < ActiveRecord::Migration[5.1]
  def change
    change_column :companies, :capital_raised, :integer, limit: 8
  end
end
