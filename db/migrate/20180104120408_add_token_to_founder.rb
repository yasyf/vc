class AddTokenToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :token, :string
    add_index :founders, :token, unique: true
  end
end
