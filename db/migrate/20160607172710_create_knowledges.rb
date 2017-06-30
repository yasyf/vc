class CreateKnowledges < ActiveRecord::Migration[5.0]
  def change
    create_table :knowledges do |t|
      t.text :body, null: false, blank: false
      t.belongs_to :user, index: true, foreign_key: true
      t.string :ts, null: false, blank: false, index: true, unique: true

      t.timestamps null: false
    end
  end
end
