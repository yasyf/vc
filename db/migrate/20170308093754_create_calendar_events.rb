class CreateCalendarEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :calendar_events, id: :string do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :company, foreign_key: true
      t.string :notes_doc_link

      t.timestamps
    end
  end
end
