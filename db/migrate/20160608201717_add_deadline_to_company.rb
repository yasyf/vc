class AddDeadlineToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :deadline, :date, null: true
  end
end
