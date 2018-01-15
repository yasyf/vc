class AddSlowQueryIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :companies, :location
  end
end
