class AddFeaturedToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :featured, :boolean, null: false, default: false
  end
end
