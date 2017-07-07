class CreateInvestors < ActiveRecord::Migration[5.1]
  def change
    create_table :investors do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :crunchbase_id
      t.string :role
      t.belongs_to :competitor, foreign_key: true, null: false

      t.index :email, unique: true
      t.index :crunchbase_id, unique: true

      t.timestamps
    end
  end
end
