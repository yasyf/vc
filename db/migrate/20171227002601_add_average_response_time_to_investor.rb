class AddAverageResponseTimeToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :average_response_time, :integer
  end
end
