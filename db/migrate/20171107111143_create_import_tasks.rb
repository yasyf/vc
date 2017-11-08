class CreateImportTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :import_tasks do |t|
      t.belongs_to :founder, foreign_key: true, null: false
      t.jsonb :headers, default: '{}'
      t.jsonb :samples, array: true, default: []
      t.boolean :complete, null: false, default: false
      t.string :header_row, array: true
      t.integer :total
      t.integer :imported
      t.string :error_message
      t.jsonb :errored, array: true, default: []

      t.timestamps
    end
  end
end
