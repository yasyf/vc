class CrawlTweetsJob < ApplicationJob
  include Concerns::Batchable
  queue_as :long

  MAX_DELAY = 6.hours
  LIMIT_FACTOR = 1

  def perform
    run_job_in_batches(Investor, CrawlInvestorTweetsJob)
  end
end
