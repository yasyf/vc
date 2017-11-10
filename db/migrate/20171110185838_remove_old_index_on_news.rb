class RemoveOldIndexOnNews < ActiveRecord::Migration[5.1]
  def change
    remove_index :news, [:url, :investor_id]
  end
end
