class RefreshJob < ApplicationJob
  include Concerns::Batchable
  queue_as :default

  MAX_DELAY = 2.days
  LIMIT_FACTOR = 4

  def perform(max_delay: nil, limit_factor: nil)
    run_job_in_batches(Investor, InvestorCrunchbaseJob, max_delay: max_delay, limit_factor: limit_factor)
    run_job_in_batches(Competitor, CompetitorCrunchbaseJob, max_delay: max_delay, limit_factor: limit_factor)
    run_job_in_batches(Company, CompanyRelationshipsJob, max_delay: max_delay, limit_factor: limit_factor)
  end
end
