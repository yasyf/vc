class AddSocialFieldsToInvestors < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :photo, :string
    add_column :investors, :twitter, :string
    add_column :investors, :linkedin, :string
    add_column :investors, :facebook, :string
    add_column :investors, :homepage, :string

    add_index :investors, :photo, unique: true
    add_index :investors, :twitter, unique: true
    add_index :investors, :facebook, unique: true
    add_index :investors, :linkedin, unique: true
    add_index :investors, :homepage, unique: true
  end
end
