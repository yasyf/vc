class Tweet < ApplicationRecord
  def self.wrap
    Array.wrap(yield).compact.map { |t| where(twitter_id: t.id).first_or_create! }
  end

  def method_missing(m, *args, &block)
    raw_tweet.send(m, *args, &block)
  end

  def raw_tweet
    @raw_tweet ||= TwitterApi::Client.new.client.status(twitter_id)
  end
end
