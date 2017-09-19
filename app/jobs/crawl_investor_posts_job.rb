class CrawlInvestorPostsJob < ApplicationJob
  queue_as :default

  def perform(investor_id)
    investor = Investor.find(investor_id)
    return unless investor.blog_url.present?
    investor.crawl_posts!
  end
end
