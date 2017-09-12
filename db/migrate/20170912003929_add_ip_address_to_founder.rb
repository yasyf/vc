class AddIpAddressToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :ip_address, :inet
  end
end
