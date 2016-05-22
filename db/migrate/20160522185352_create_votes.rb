class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :fit, blank: false, null: false
      t.integer :team, blank: false, null: false
      t.integer :product, blank: false, null: false
      t.integer :market, blank: false, null: false
      t.integer :overall
      t.text :reason
      t.boolean :final, null: false
      t.belongs_to :user, index: true
      t.belongs_to :company, index: true

      t.timestamps null: false

      t.index [:company_id, :user_id, :final], unique: true
    end
    add_foreign_key :votes, :users
  end
end
