class RenameCompaniesCompetitorsToInvestments < ActiveRecord::Migration[5.1]
  def change
    rename_table :companies_competitors, :investments
  end
end
