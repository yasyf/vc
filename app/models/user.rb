class User < ActiveRecord::Base
  include Concerns::Slackable
  include Concerns::Cacheable

  QUORUM_PERCENTAGE = 0.6

  has_many :votes

  validates :username, presence: true, uniqueness: true

  devise :omniauthable, omniauth_providers: [:google_oauth2]

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

  def active?
    (inactive_since.blank? || inactive_since >= Time.now) && created_at <= Time.now
  end

  def toggle_active!
    update!(inactive_since: active? ? Time.now : nil)
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
    "#{username}@#{ENV['DOMAIN']}"
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

  def self.from_omniauth(auth)
    from_username_domain *auth.info['email'].split('@')
  end

  def self.from_slack(slack_id)
    user = slack_client_factory.users_info(user: slack_id).user
    from_username_domain *user.profile.email.split('@')
  rescue Slack::Web::Api::Error
    nil
  end

  def self.from_username_domain(username, domain)
    return nil unless domain == ENV['DOMAIN']
    where(username: username).first_or_create!
  end

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
