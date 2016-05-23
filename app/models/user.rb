class User < ActiveRecord::Base
  QUORUM_PERCENTAGE = 0.6

  has_many :votes

  validates :username, presence: true, uniqueness: true

  scope :inactive, Proc.new { |since| where('inactive_since <= ?', since || Time.now) }
  scope :active, Proc.new { |since| inactive(since).not }

  def self.quorum
    @quorum ||= (active.count * QUORUM_PERCENTAGE).to_i
  end

  def stats
    {
      yes_votes: votes.yes.count,
      no_votes: votes.no.count,
      agreed: agreed,
      disagreed: disagreed,
      averages: averages
    }
  end

  private

  def agreed
    company_votes.select { |c, v| c.funded? && v.yes? }.count
  end

  def disagreed
    company_votes.size - agreed
  end

  def company_votes
    @company_votes ||= votes.map { |vote| [vote.company, vote] }.to_h
  end

  def averages
    Votes::METRICS.map { |metric| [metric, votes.select(metric).average] }.to_h
  end
end
