class AddTokensToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :access_token, :string
    add_column :founders, :refresh_token, :string
  end
end
