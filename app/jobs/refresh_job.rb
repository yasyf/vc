class RefreshJob < ApplicationJob
  queue_as :default

  MAX_DELAY = 2.week

  def perform
    run_job_in_batches(Investor, InvestorCrunchbaseJob)
    run_job_in_batches(Competitor, CompetitorCrunchbaseJob)
    run_job_in_batches(Company, CompanyRelationshipsJob)
  end

  private

  def run_job_in_batches(klass, job)
    klass.in_batches do |scope|
      scope.pluck(:id).each { |id| job.set(queue: :low, wait: MAX_DELAY * rand).perform_later(id) }
    end
  end
end
