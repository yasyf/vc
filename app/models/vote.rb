class Vote < ActiveRecord::Base
  METRICS = %w(fit team product market)

  belongs_to :user
  belongs_to :company

  validates :company, uniqueness: { scope: [:user, :final] }
  validates :final, inclusion: [true, false]
  validates :overall, numericality: { in: 1..5 }, if: :final?
  validates :reason, presence: true, if: :final?

  METRICS.each { |metric| validates metric, numericality: { in: 1..5 } }
end
