class CreateInvestorProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :investor_profiles do |t|
      t.belongs_to :founder, foreign_key: true
      t.string :city
      t.string :industry, array: true
      t.integer :funding_size

      t.timestamps
    end
  end
end
