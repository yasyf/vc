class AddInvestorToCompaniesCompetitors < ActiveRecord::Migration[5.1]
  def change
    add_reference :companies_competitors, :investor, foreign_key: true
  end
end
