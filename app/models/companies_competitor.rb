class CompaniesCompetitor < ApplicationRecord
  belongs_to :company
  belongs_to :competitor
  belongs_to :investor

  def self.assign_to_investor(investor, company, no_replace: false)
    scope = where(competitor: investor.competitor, company: company)
    return if no_replace && scope.first.present? && scope.first.investor.present?
    scope.update_all investor_id: investor.id
  end
end
