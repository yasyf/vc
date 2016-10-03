class AddCachedFundedToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :cached_funded, :boolean, null: false, default: false
    Company.reset_column_information
    Company.all.each do |company|
      company.cached_funded = company.funded?
      company.save! if company.changed?
    end
  end
end
