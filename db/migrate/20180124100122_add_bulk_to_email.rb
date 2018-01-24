class AddBulkToEmail < ActiveRecord::Migration[5.1]
  def change
    add_column :emails, :bulk, :boolean, null: false, default: false
  end
end
