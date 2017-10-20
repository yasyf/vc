class ChangeFundedAtNullOnInvestments < ActiveRecord::Migration[5.1]
  def change
    change_column_null :investments, :funded_at, true
    change_column_default :investments, :funded_at, nil
  end
end
