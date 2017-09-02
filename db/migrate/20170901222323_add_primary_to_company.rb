class AddPrimaryToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :primary, :boolean, null: false, default: false
  end
end
