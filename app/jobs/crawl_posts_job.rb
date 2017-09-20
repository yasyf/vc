class CrawlPostsJob < ApplicationJob
  include Concerns::Batchable
  queue_as :default

  MAX_DELAY = 12.hours
  LIMIT_FACTOR = 4

  def perform
    run_job_in_batches(Investor, CrawlInvestorPostsJob)
  end
end
