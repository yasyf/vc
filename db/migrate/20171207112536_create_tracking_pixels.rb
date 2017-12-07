class CreateTrackingPixels < ActiveRecord::Migration[5.1]
  def change
    create_table :tracking_pixels do |t|
      t.belongs_to :email, foreign_key: true, null: false
      t.string :token, null: false
      t.string :open_city
      t.string :open_country
      t.integer :open_device_type
      t.datetime :opened_at

      t.index :token, unique: true

      t.timestamps
    end
  end
end
