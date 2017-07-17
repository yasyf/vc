class RemoveCommentsFromInvestor < ActiveRecord::Migration[5.1]
  def change
    remove_column :investors, :comments, :text
  end
end
