class AddDomainToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :domain, :string, unique: true
  end
end
