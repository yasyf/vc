class RefreshJob < ApplicationJob
  include Concerns::Batchable
  queue_as :default

  MAX_DELAY = 1.days
  LIMIT_FACTOR = 10

  def perform(max_delay: nil, limit_factor: nil)
    refresh_views!
    run_job_in_batches(Investor, InvestorCrunchbaseJob, max_delay: max_delay, limit_factor: limit_factor, queue: :long)
    run_job_in_batches(Competitor, CompetitorCrunchbaseJob, max_delay: max_delay, limit_factor: limit_factor)
    run_job_in_batches(Company, CompanyRelationshipsJob, max_delay: max_delay, limit_factor: limit_factor)
  end

  private

  def refresh_views!
    %w(competitor_target_counts).each do |view|
      Scenic.database.refresh_materialized_view(view, concurrently: true, cascade: true)
    end
  end
end
