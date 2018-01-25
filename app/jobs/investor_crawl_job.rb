class InvestorCrawlJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :long

  def perform(investor_id)
    ignore_invalid do
      investor = Investor.find(investor_id)
      investor.set_timezone!
      investor.set_gender!
      investor.fetch_review!
      # investor.set_average_response_time!
      investor.crawl_homepage!
      investor.crawl_posts!
      investor.fetch_news!
      investor.save!
    end
  end
end
