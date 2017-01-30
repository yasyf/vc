class RemoveRdvFundedFromCompany < ActiveRecord::Migration[5.0]
  def up
    begin
      rdv = Competitor.where(name: 'Rough Draft Ventures').first!
      rdv.update! companies: Company.where(rdv_funded: true)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Rough Draft Ventures not found"
    end
    remove_column :companies, :rdv_funded, :boolean
  end

  def down
    add_column :companies, :rdv_funded, :boolean, null: false, default: false
  end
end
