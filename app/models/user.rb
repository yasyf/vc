class User < ActiveRecord::Base
  include Concerns::Slackable
  include Concerns::Cacheable

  QUORUM_PERCENTAGE = 0.6

  has_many :votes

  validates :username, presence: true, uniqueness: true

  def self.inactive(since = Time.now)
    where(
      arel_table[:inactive_since].lt(since).
      or(arel_table[:created_at].gt(since))
    )
  end

  def self.active(since = Time.now)
    where(
      arel_table[:inactive_since].gteq(since).
      or(arel_table[:inactive_since].eq(nil))
    )
    .where(
      arel_table[:created_at].lteq(since)
    )
  end

  def self.quorum(at)
    (active(at).count * QUORUM_PERCENTAGE).to_i
  end

  def stats
    {
      yes_votes: votes.yes.count,
      no_votes: votes.no.count,
      agreed: agreed.count,
      disagreed: disagreed.count,
      averages: Vote.metrics(votes)
    }
  end

  def email
    "#{username}@dormroomfund.com"
  end

  def slack_name
    cached { "@#{slack_user.name}" }
  end

  def send!(message)
    slack_send! slack_id, message
  end

  %w(real_name first_name last_name title).each do |field|
    define_method field do
      key_cached [field] { slack_user.profile.public_send(field).titleize }
    end
  end

  alias_method :name, :real_name

  private

  def slack_id
    cached { slack_user.id }
  end

  def slack_user
    @slack_user ||= begin
      members = slack_client.users_search(user: email).members
      members = slack_client.users_search(user: username).members unless members.present?
      members.first
    end
  end

  def agreed
    @agreed ||= company_votes.select { |c, v| c.funded? == v.yes? }
  end

  def disagreed
    @disagreed ||= company_votes.except(agreed.keys)
  end

  def company_votes
    @company_votes ||= votes.includes(:company).final.map { |vote| [vote.company, vote] }.to_h
  end
end
