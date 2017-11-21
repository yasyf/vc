class AddTargetInvestorIdToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    change_table :intro_requests do |t|
      t.belongs_to :target_investor, foreign_key: true
    end
  end
end
