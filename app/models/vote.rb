class Vote < ActiveRecord::Base
  METRICS = %w(fit team product market)

  belongs_to :user
  belongs_to :company

  validates :company, presence: true, uniqueness: { scope: [:user, :final] }
  validates :final, inclusion: [true, false]
  validates :overall, numericality: { in: (1..5).to_a - [3] }, if: :final?
  validates :reason, presence: true, if: :final?

  METRICS.each { |metric| validates metric, numericality: { in: 1..5 } }

  scope :final, -> { where(final: true) }
  scope :valid, Proc.new { |since| final.joins(:user).merge User.active(since) }
  scope :yes, -> { final.where('overall > ?', 3) }
  scope :no, -> { final.where('overall < ?', 3) }

  def yes?
    overall > 3
  end

  def no?
    !yes?
  end

  def self.metrics(votes)
    METRICS.map { |metric| [metric, votes.select(metric).average] }.to_h
  end
end
