class CreateTargetInvestors < ActiveRecord::Migration[5.1]
  def change
    create_table :target_investors do |t|
      t.belongs_to :investor, foreign_key: true, null: false
      t.belongs_to :founder, foreign_key: true, null: false
      t.integer :stage, null: false, default: 0
      t.integer :tier, null: false, default: 1
      t.datetime :last_response

      t.index [:investor_id, :founder_id], unique: true

      t.timestamps
    end
  end
end
