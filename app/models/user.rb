class User < ActiveRecord::Base
  include Concerns::Slackable

  QUORUM_PERCENTAGE = 0.6

  has_many :votes

  validates :username, presence: true, uniqueness: true

  scope :inactive, Proc.new { |since| where('inactive_since <= ?', since || Time.now) }
  scope :active, Proc.new { |since| where.not(inactive(since).where_values) }

  def self.quorum
    @quorum ||= (active.count * QUORUM_PERCENTAGE).to_i
  end

  def stats
    {
      yes_votes: votes.yes.count,
      no_votes: votes.no.count,
      agreed: agreed,
      disagreed: disagreed,
      averages: Votes.metrics(votes)
    }
  end

  def first_name
    name.split.first
  end

  def email
    "#{username}@dormroomfund.com"
  end

  def slack_name
    "@#{slack_user.name}"
  end

  def send!(message)
    slack_send! slack_id, message
  end

  private

  def slack_id
    @slack_user ||= slack_user.id
  end

  def slack_user
    @slack_user ||= begin
      members = slack_client.users_search(user: first_name).members
      members = slack_client.users_search(user: username).members unless members.present?
      members.first
    end
  end

  def agreed
    company_votes.select { |c, v| c.funded? && v.yes? }.count
  end

  def disagreed
    company_votes.size - agreed
  end

  def company_votes
    @company_votes ||= votes.map { |vote| [vote.company, vote] }.to_h
  end
end
