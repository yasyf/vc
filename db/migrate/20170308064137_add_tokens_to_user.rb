class AddTokensToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :access_token, :string
    add_column :users, :refresh_token, :string
  end
end
