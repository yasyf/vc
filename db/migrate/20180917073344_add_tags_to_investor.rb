class AddTagsToInvestor < ActiveRecord::Migration[5.2]
  def change
    add_column :investors, :tags, :string, array: true
  end
end
