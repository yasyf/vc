class TargetInvestor < ApplicationRecord
  belongs_to :investor
  belongs_to :founder

  enum stage: %w(added intro waiting respond interested pass)

  validates :investor, presence: true, uniqueness: { scope: [:founder] }
  validates :founder, presence: true
  validates :stage, presence: true
  validates :tier, presence: true, numericality: { greater_than: 0, only_integer: true }

  def as_json(options = {})
    super options.reverse_merge(only: [:stage, :tier, :id], methods: [:investor])
  end
end
