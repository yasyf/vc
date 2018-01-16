class AddMissingIndexesToInvestments < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        execute 'DELETE FROM investments WHERE NOT EXISTS (SELECT 1 FROM competitors WHERE competitors.id = investments.competitor_id);'
        execute 'DELETE FROM investments WHERE NOT EXISTS (SELECT 1 FROM companies WHERE companies.id = investments.company_id);'
      end
    end
    add_foreign_key :investments, :competitors
    add_foreign_key :investments, :companies
  end
end
