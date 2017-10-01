class AddMetricsToModel < ActiveRecord::Migration[5.1]
  def change
    add_column :models, :metrics, :hstore
  end
end
