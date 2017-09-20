class RefreshJob < ApplicationJob
  include Concerns::Batchable
  queue_as :default

  MAX_DELAY = 1.week
  LIMIT_FACTOR = 4

  def perform
    run_job_in_batches(Investor, InvestorCrunchbaseJob)
    run_job_in_batches(Competitor, CompetitorCrunchbaseJob)
    run_job_in_batches(Company, CompanyRelationshipsJob)
  end
end
