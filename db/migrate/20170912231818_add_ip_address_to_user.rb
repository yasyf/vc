class AddIpAddressToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :ip_address, :inet
  end
end
