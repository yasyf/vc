class CrawlPostsJob < ApplicationJob
  queue_as :default

  MAX_DELAY = 12.hours

  def perform
    Investor.all.find_each do |investor|
      next unless investor.blog_url.present?
      CrawlInvestorPostsJob.set(queue: :low, wait: MAX_DELAY * rand).perform_later investor.id
    end
  end
end
