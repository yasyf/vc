class RemoveRdvFundedFromCompany < ActiveRecord::Migration[5.0]
  def up
    rdv = Competitor.where(name: 'Rough Draft Ventures').first!
    rdv.update! companies: Company.where(rdv_funded: true)
    remove_column :companies, :rdv_funded, :boolean
  end

  def down
    add_column :companies, :rdv_funded, :boolean, null: false, default: false
  end
end
