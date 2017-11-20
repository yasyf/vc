class AddResponseTimeToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :response_time, :integer
  end
end
