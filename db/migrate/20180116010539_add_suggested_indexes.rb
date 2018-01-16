class AddSuggestedIndexes < ActiveRecord::Migration[5.1]
  def change
    commit_db_transaction
    add_index :competitors, [:domain], algorithm: :concurrently
    add_index :entities, [:wiki], algorithm: :concurrently
  end
end
