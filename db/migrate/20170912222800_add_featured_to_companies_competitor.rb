class AddFeaturedToCompaniesCompetitor < ActiveRecord::Migration[5.1]
  def change
    add_column :companies_competitors, :featured, :boolean, default: false
  end
end
