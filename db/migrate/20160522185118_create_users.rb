class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username, blank: false, null: false, index: true, unique: true
      t.datetime :inactive_since

      t.timestamps null: false
    end
  end
end
