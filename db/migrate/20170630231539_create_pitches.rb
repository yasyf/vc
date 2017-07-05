class CreatePitches < ActiveRecord::Migration[5.1]
  def change
    create_table :pitches do |t|
      t.datetime :when, null: false
      t.datetime :decision
      t.datetime :deadline
      t.boolean :funded, null: false, default: false
      t.belongs_to :company, foreign_key: true, index: true, null: false
      t.string :snapshot
      t.string :prevote_doc

      t.index :snapshot, unique: true
      t.index :prevote_doc, unique: true

      t.timestamps
    end
  end
end
