class CreatePitches < ActiveRecord::Migration[5.1]
  def change
    create_table :pitches do |t|
      t.datetime :when, null: false
      t.datetime :decision
      t.boolean :cached_funded
      t.belongs_to :company, foreign_key: true, null: false

      t.timestamps
    end
  end
end
