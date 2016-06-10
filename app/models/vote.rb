class EligibleValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:user] << 'must be active' if !record.user.active?
    record.errors[:company] << 'voting deadline has passed' if record.company.past_deadline?
  end
end

class Vote < ActiveRecord::Base
  METRICS = %w(fit team product market)

  belongs_to :user
  belongs_to :company, touch: true

  validates :company, presence: true, uniqueness: { scope: [:user, :final] }
  validates :final, inclusion: [true, false]
  validates :overall, inclusion: { in: (1..5).to_a - [3], message: 'cannot be 3' }, if: :final?
  validates :reason, presence: true, if: :final?
  validates_with EligibleValidator, unless: :skip_eligibility?

  METRICS.each do |metric|
    validates metric, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true }
  end

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

  def warn!(time_remaining)
    VoteMailer.email_and_slack!(:vote_warning_email, user, company, time_remaining.to_i)
  end

  def self.metrics(votes)
    METRICS.map { |metric| [metric, votes.average(metric) || 0.0] }.to_h
  end

  def skip_eligibility!
    @skip_eligibility = true
  end

  private

  def skip_eligibility?
    @skip_eligibility
  end
end
