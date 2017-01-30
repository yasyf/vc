class Tweeter < ApplicationRecord
  NEWSWORTHY_THRESHOLD = 3
  NEWSWORTHY_MIN = 1

  def newsworthy_tweets(n = 5)
    tweets = latest_tweets(n**2)
    count = tweets.count.to_f

    threshold = lambda { |name| [NEWSWORTHY_THRESHOLD * (tweets.map(&name).sum / count), NEWSWORTHY_MIN].max }

    fave_threshold = threshold[:favorite_count]
    rt_threshold = threshold[:retweet_count]

    tweets.select { |t| t.favorite_count > fave_threshold && t.retweet_count > rt_threshold }
  end

  private

  def latest_tweets(n = 5)
    client.user_timeline(username, count: n * 2, include_rts: false, exclude_replies: true).first(n)
  end

  def client
    @client ||= TwitterApi::Client.new.client
  end
end
