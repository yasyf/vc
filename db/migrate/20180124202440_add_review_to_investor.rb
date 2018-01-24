class AddReviewToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :review, :hstore
  end
end
