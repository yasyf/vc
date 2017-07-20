class CompanyNewsJob < ApplicationJob
  queue_as :default

  def perform
    Company.includes(tweeter: :tweets).portfolio.map(&:tweeter).compact.each do |tweeter|
      tweet = tweeter.newsworthy_tweets.last
      next unless tweet.present? && !tweet.shared?
      tweet.share!
    end
  end
end
