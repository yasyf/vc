class Tweet < ApplicationRecord
  include Concerns::Cacheable
  include Concerns::Slackable
  include Concerns::Twitterable

  validates :twitter_id, presence: true, uniqueness: true
  validates :shared, inclusion: [true, false]

  def self.wrap
    Array.wrap(yield).compact.map { |t| where(twitter_id: t.id).first_or_create! }
  end

  def method_missing(m, *args, &block)
    raw_tweet&.send(m, *args, &block)
  end

  def share!
    update! shared: true
    slack_send! ENV['NEWS_CHANNEL'], url
  end

  private

  def raw_tweet
    @raw_tweet ||= cached { twitter_client.with_client { |c| c.status(twitter_id) } }
  end
end
