class CreateIntroRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :intro_requests do |t|
      t.string :token, null: false
      t.boolean :accepted, null: false, default: false
      t.belongs_to :investor, foreign_key: true, null: false
      t.belongs_to :company, foreign_key: true, null: false
      t.belongs_to :founder, foreign_key: true, null: false

      t.timestamps

      t.index :token, unique: true
      t.index [:investor_id, :founder_id, :company_id], unique: true, name: 'index_intro_requests_on_investor_founder_and_company_id'
    end
  end
end
