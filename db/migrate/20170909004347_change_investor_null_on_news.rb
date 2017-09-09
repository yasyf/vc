class ChangeInvestorNullOnNews < ActiveRecord::Migration[5.1]
  def change
    change_column_null :news, :investor_id, true
  end
end
