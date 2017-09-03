class CreateEmails < ActiveRecord::Migration[5.1]
  def change
    create_table :emails do |t|
      t.text :body
      t.float :sentiment_score
      t.float :sentiment_magnitude
      t.belongs_to :founder, foreign_key: true, null: false
      t.belongs_to :company, foreign_key: true, null: false
      t.belongs_to :investor, foreign_key: true, null: false
      t.integer :direction, null: false
      t.integer :old_stage
      t.integer :new_stage

      t.timestamps
    end
  end
end
