class AddEmailToTargetInvestors < ActiveRecord::Migration[5.1]
  def change
    add_column :target_investors, :email, :string
  end
end
