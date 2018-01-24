class AddIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :investors, :hidden
    add_index :emails, :bulk
  end
end
