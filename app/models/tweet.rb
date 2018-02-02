class Tweet < ApplicationRecord
  include Concerns::Cacheable
  include Concerns::Slackable
  include Concerns::Twitterable

  belongs_to :tweeter
  validates :twitter_id, presence: true, uniqueness: true
  validates :shared, inclusion: [true, false]
  scope :unseen, -> { where(shared: false) }

  def self.wrap(tweeter)
    Array.wrap(yield).compact.map do |t|
      next unless t.id.present?
      where(twitter_id: t.id).first_or_create! do |tweet|
        tweet.tweeter = tweeter
        tweet.tweeted_at = t.created_at
        tweet.text = t.text
      end
    end.compact
  end

  def method_missing(m, *args, &block)
    raw_tweet&.send(m, *args, &block)
  end

  def share!
    mark_as_seen!
    slack_send! ENV['NEWS_CHANNEL'], "#{tweeter.owner.name} has a newsworthy tweet!\n#{url}"
    prepare_for_writing!
    twitter_client.with_client { |c| c.retweet! raw_tweet }
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:twitter_id, :text, :tweeted_at])
  end

  def url
    "https://twitter.com/#{tweeter.username}/status/#{twitter_id}"
  end

  def prepare_for_writing!
    self.twitter_opts.merge!(write: true)
  end

  def mark_as_seen!
    update! shared: true
  end

  private

  def raw_tweet
    @raw_tweet ||= twitter_client.with_client { |c| c.status(twitter_id) }
  end
end
