class AddTimeZoneToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :time_zone, :string
  end
end
