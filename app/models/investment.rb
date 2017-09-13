class Investment < ApplicationRecord
  belongs_to :company
  belongs_to :competitor
  belongs_to :investor

  def self.assign_to_investor(investor, company, featured: false, no_replace: false)
    scope = where(competitor: investor.competitor, company: company)
    if (existing = scope.first).present?
      existing.investor = investor unless no_replace
      existing.featured = featured if featured
      existing.tap(&:save!)
    else
      scope.first_or_create!(investor: investor, featured: featured)
    end
  end
end
