class CrawlTweetsJob < ApplicationJob
  include Concerns::Batchable
  queue_as :default

  MAX_DELAY = 3.hours
  LIMIT_FACTOR = 4

  def perform
    run_job_in_batches(Investor, CrawlInvestorTweetsJob)
  end
end
