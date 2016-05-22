class Vote < ActiveRecord::Base
  METRICS = %w(fit team product market)

  belongs_to :user
  belongs_to :company

  validates :company, uniqueness: { scope: [:user, :final] }
  validates :final, inclusion: [true, false]
  validates :overall, numericality: { greater_than:0, less_than:6 }, if: :final?
  validates :reason, presense: true, if: :final?

  METRICS.each { |metric| validates metric, numericality: { greater_than:0, less_than:6 } }
end
