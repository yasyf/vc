class AddVerifiedToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :verified, :boolean, null: false, default: false
    add_column :competitors, :verified, :boolean, null: false, default: false
  end
end
