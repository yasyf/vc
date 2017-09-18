class CrawlInvestorPostsJob < ApplicationJob
  queue_as :default

  def perform(investor_id)
    return unless investor.blog_url.present?
    Investor.find(investor_id).crawl_posts!
  end
end
