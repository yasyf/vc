class AddIndexToNews < ActiveRecord::Migration[5.1]
  def change
    add_index :news, [:url, :investor_id, :company_id], unique: true
  end
end
