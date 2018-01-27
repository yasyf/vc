class CrawlTweetsJob < ApplicationJob
  include Concerns::Batchable
  queue_as :long

  MAX_DELAY = 1.hours
  LIMIT_FACTOR = 2

  def perform
    run_job_in_batches(Investor, CrawlInvestorTweetsJob, queue: :long)
  end
end
