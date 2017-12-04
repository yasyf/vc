class AddHistoryIdToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :history_id, :bigint
  end
end
