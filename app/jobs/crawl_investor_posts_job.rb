class CrawlInvestorPostsJob < ApplicationJob
  queue_as :default

  def perform(investor_id)
    Investor.find(investor_id).crawl_posts!
  end
end
