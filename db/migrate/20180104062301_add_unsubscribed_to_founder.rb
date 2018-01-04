class AddUnsubscribedToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :unsubscribed, :boolean, null: false, default: false
  end
end
