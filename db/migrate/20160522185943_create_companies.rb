class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, blank: false, null: false, index: true
      t.string :trello_id, blank: false, null: false, index: true, unique: true
      t.date :pitch_on
      t.datetime :decision_at

      t.timestamps null: false
    end
  end
end
