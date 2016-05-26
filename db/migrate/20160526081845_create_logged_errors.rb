class CreateLoggedErrors < ActiveRecord::Migration
  def change
    create_table :logged_errors do |t|
      t.text :reason, null: false
      t.integer :record_id, null: false
      t.integer :count, null: false, default: 0

      t.timestamps null: false

      t.index [:reason, :record_id], unique: true
    end
  end
end
