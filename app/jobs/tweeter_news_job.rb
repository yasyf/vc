class TweeterNewsJob < ApplicationJob
  queue_as :default

  def perform(tweeter_id)
    tweeter = Tweeter.find(tweeter_id)
    tweet = tweeter.newsworthy_tweets.last
    return unless tweet.present? && !tweet.shared?
    tweet.share!
  end
end
