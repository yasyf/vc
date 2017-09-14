class CrawlTweetsJob < ApplicationJob
  queue_as :default

  MAX_DELAY = 30.minutes

  def perform
    Investor.where.not(twitter: nil).find_each do |investor|
      CrawlInvestorTweetsJob.set(queue: :low, wait: MAX_DELAY * rand).perform_later investor.id
    end
  end
end
