class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, blank: false, null: false, index: true
      t.string :trello_id, blank: false, null: false, index: true, unique: true
      t.datetime :pitch_on

      t.timestamps null: false
    end
  end
end
