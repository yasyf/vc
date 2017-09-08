class CompaniesCompetitor < ApplicationRecord
  belongs_to :company
  belongs_to :competitor
  belongs_to :investor

  def self.assign_to_investor(investor, company)
    where(competitor: investor.competitor, company: company).update_all investor_id: investor.id
  end
end
