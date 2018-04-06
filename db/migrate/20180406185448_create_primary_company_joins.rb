class CreatePrimaryCompanyJoins < ActiveRecord::Migration[5.1]
  def change
    create_view :primary_company_joins, materialized: true
    add_index :primary_company_joins, :founder_id, unique: true
  end
end
