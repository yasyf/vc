class AddDeadlineToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :deadline, :date, null: true
  end
end
