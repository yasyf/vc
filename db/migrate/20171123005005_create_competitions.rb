class CreateCompetitions < ActiveRecord::Migration[5.1]
  def change
    create_table :competitions do |t|
      t.belongs_to :a, foreign_key: { to_table: :companies }, null: false
      t.belongs_to :b, foreign_key: { to_table: :companies }, null: false

      t.timestamps

      t.index [:a_id, :b_id], unique: true
    end
  end
end
