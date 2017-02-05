class Tweet < ApplicationRecord
  include Concerns::Slackable

  validates :twitter_id, presence: true, uniqueness: true
  validates :shared, inclusion: [true, false]

  def self.wrap
    Array.wrap(yield).compact.map { |t| where(twitter_id: t.id).first_or_create! }
  end

  def method_missing(m, *args, &block)
    raw_tweet.send(m, *args, &block)
  end

  def share!
    update! shared: true
    slack_send! ENV['NEWS_CHANNEL'], url
  end

  private

  def raw_tweet
    @raw_tweet ||= TwitterApi::Client.new.client.status(twitter_id)
  end
end
