class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, blank: false, null: false, index: true, unique: true
      t.string :name, blank: false, null: false
      t.datetime :inactive_since

      t.timestamps null: false
    end
  end
end
