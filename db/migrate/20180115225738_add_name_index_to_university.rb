class AddNameIndexToUniversity < ActiveRecord::Migration[5.1]
  def change
    add_index :universities, :name
  end
end
