class AddCommentsToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :comments, :text
  end
end
