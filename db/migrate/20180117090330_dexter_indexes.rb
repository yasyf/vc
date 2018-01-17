class DexterIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :companies, :description
  end
end
