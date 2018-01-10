class CrawlInvestorTweetsJob < ApplicationJob
  queue_as :long

  def perform(investor_id)
    Investor.find(investor_id).scrape_tweets!
  end
end
