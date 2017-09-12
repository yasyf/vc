class CrawlPostsJob < ApplicationJob
  queue_as :default

  def perform
    Investor.all.find_each do |investor|
      next unless investor.blog_url.present?
      CrawlInvestorPostsJob.perform_later investor.id
    end
  end
end
