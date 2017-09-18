class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.references :subject, polymorphic: true, index: true, null: false
      t.string :action, null: false
      t.string :arg1
      t.string :arg2
      t.string :arg3

      t.timestamps
    end
  end
end
