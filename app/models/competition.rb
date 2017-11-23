class Competition < ApplicationRecord
  belongs_to :a, class_name: Company.name
  belongs_to :b, class_name: Company.name

  validates :a, presence: true
  validates :b, presence: true, uniqueness: { scope: :a }

  def self.from_companies!(a, b)
    sorted = [a, b].sort_by(&:id)
    where(a: sorted.first, b: sorted.last).first_or_create!
  end

  def self.for_companies(company_ids)
    as = Competition.where(a: company_ids).select('b_id')
    bs = Competition.where(b: company_ids).select('a_id')
    Company.where(id: as).or(Company.where(id: bs))
  end
end
