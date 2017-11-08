class AddCompetitorToTargetInvestor < ActiveRecord::Migration[5.1]
  def change
    add_reference :target_investors, :competitor, foreign_key: true
    add_index :target_investors, [:first_name, :last_name, :firm_name, :founder_id], unique: true, name: 'index_target_investors_on_first_last_firm_name'
  end
end
