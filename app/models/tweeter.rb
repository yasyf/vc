class Tweeter < ApplicationRecord
  include Concerns::Twitterable

  NEWSWORTHY_THRESHOLD = 3
  NEWSWORTHY_MIN = 10

  belongs_to :owner, polymorphic: true
  has_many :tweets, dependent: :destroy
  validates :username, presence: true, uniqueness: true

  def newsworthy_tweets(n = 5)
    tweets = latest_tweets(n**2)
    count = tweets.count.to_f

    return [] unless tweets.present?

    threshold = lambda { |name| [NEWSWORTHY_THRESHOLD * (tweets.map(&name).sum / count), NEWSWORTHY_MIN].max }

    fave_threshold = threshold[:favorite_count]
    rt_threshold = threshold[:retweet_count]

    Tweet.wrap(self) do
      tweets.select { |t| t.favorite_count > fave_threshold && t.retweet_count > rt_threshold }
    end
  end

  def latest_tweets(n = 5)
    Tweet.wrap(self) { latest_tweets_raw(n) }
  end

  private

  def latest_tweets_raw(n)
    twitter_client.with_client([]) do |client|
      client.user_timeline(username, count: n * 2, include_rts: false, exclude_replies: true).first(n)
    end
  end
end
