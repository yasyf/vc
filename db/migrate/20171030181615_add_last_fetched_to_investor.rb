class AddLastFetchedToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :last_fetched, :datetime
  end
end
