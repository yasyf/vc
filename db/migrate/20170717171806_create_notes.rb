class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.belongs_to :founder, foreign_key: true, null: false
      t.text :body, null: false
      t.references :subject, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
