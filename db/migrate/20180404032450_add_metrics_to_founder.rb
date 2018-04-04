class AddMetricsToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :affiliated_exits, :integer
    add_column :founders, :cb_id, :string
    add_column :companies, :acquisition_date, :date
    add_column :companies, :ipo_date, :date
    add_column :companies, :ipo_valuation, :integer, limit: 8
  end
end
