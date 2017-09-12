class AddTimeZoneToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :time_zone, :string
  end
end
