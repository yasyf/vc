class RestructureTargetInvestors < ActiveRecord::Migration[5.1]
  def change
    change_table :target_investors do |t|
      t.string :firm_name
      t.string :first_name
      t.string :last_name
      t.string :role

      t.change :investor_id, :bigint, null: true

      t.remove :tier

      t.remove :industry
      t.string :industry, array: true
      t.index :industry, using: 'gin'
    end
  end
end
