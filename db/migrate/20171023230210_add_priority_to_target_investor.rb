class AddPriorityToTargetInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :target_investors, :priority, :string
  end
end
