class AddFieldsToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :rdv_funded, :boolean, null: false, default: false
    add_column :companies, :capital_raised, :integer, null: false, default: 0
    add_column :companies, :description, :text
  end
end
