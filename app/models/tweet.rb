class Tweet < ApplicationRecord
  include Concerns::Cacheable
  include Concerns::Slackable
  include Concerns::Twitterable

  belongs_to :tweeter
  validates :twitter_id, presence: true, uniqueness: true
  validates :shared, inclusion: [true, false]

  def self.wrap(tweeter)
    Array.wrap(yield).compact.map do |t|
      where(twitter_id: t.id).first_or_create! do |tweet|
        tweet.tweeter = tweeter
      end
    end
  end

  def method_missing(m, *args, &block)
    raw_tweet.send(m, *args, &block)
  end

  def share!
    update! shared: true
    slack_send! ENV['NEWS_CHANNEL'], "#{tweeter.company.name} has a newsworthy tweet!\n#{url}"
    twitter_client.with_client { |c| c.retweet! raw_tweet }
  end

  private

  def raw_tweet
    @raw_tweet ||= cached { twitter_client.with_client { |c| c.status(twitter_id) } }
  end
end
