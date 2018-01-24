class InvestorCrawlJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :long

  def perform(investor_id)
    investor = Investor.find(investor_id)
    investor.crawl_homepage!
    investor.crawl_posts!
    investor.fetch_news!
    investor.set_timezone!
    investor.set_gender!
    # investor.set_average_response_time!
    ignore_invalid { investor.save! } if investor.changed?
  end
end
