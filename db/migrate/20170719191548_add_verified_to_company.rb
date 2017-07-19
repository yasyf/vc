class AddVerifiedToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :verified, :boolean, null: false, default: false
  end
end
