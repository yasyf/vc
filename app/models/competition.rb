class Competition < ApplicationRecord
  belongs_to :a, class_name: Company.name
  belongs_to :b, class_name: Company.name

  validates :a, presence: true
  validates :b, presence: true, uniqueness: { scope: :a }

  def self.from_companies!(a, b)
    sorted = [a, b].sort_by(&:id)
    where(a: sorted.first, b: sorted.last).first_or_create!
  end
end
