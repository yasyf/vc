class EligibleValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:user] << 'must be active' unless record.user.active?
    record.errors[:company] << 'voting deadline has passed' unless record.pitch.undecided?
  end
end

class Vote < ActiveRecord::Base
  METRICS = %w(fit team product market)

  belongs_to :user
  belongs_to :pitch, touch: true
  has_one :company, through: :pitch

  validates :pitch, presence: true, uniqueness: { scope: [:user, :final] }
  validates :final, inclusion: [true, false]
  validates :overall, inclusion: { in: (1..5).to_a - [3], message: 'cannot be 3' }, if: :final?
  validates :reason, presence: true, if: :final?
  validates_with EligibleValidator, unless: :skip_eligibility?

  METRICS.each do |metric|
    validates metric, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true }
  end

  scope :final, -> { where(final: true) }
  scope :valid, Proc.new { |team, since| final.joins(:user).merge User.active(team, since) }
  scope :yes, -> { final.where('votes.overall > ?', 3) }
  scope :no, -> { final.where('votes.overall < ?', 3) }

  def yes?
    overall.present? && overall > 3
  end

  def no?
    overall.present? && !yes?
  end

  def warn!(time_remaining)
    VoteMailer.email_and_slack!(:vote_warning_email, user, company, time_remaining.to_i)
  end

  def self.metrics(votes)
    size = votes.to_a.length.to_f || 1.0
    METRICS.map { |metric| [metric, votes.map { |v| v.send(metric) }.sum / size] }.to_h
  end

  def skip_eligibility!
    @skip_eligibility = true
  end

  def stats
    {
      yes_votes: yes? ? 1 : 0,
      no_votes: no? ? 1 : 0,
      averages: metrics
    }.with_indifferent_access
  end

  def metrics
    METRICS.map { |metric| [metric, public_send(metric] }.to_h
  end

  def as_json(options = {})
    options.reverse_merge!(
      only: [:created_at, :fit, :team, :product, :market, :overall, :reason, :final]
    )
    super(options).merge(
      user: user.name,
      company: company.name,
    )
  end

  private

  def skip_eligibility?
    @skip_eligibility
  end
end
