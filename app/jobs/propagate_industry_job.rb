class PropagateIndustryJob < ApplicationJob
  queue_as :low

  def perform
    PropagateIndustryUpJob.perform_later 'Investor'
    PropagateIndustryUpJob.perform_later 'Competitor'
    PropagateFundTypeUpJob.perform_later 'Competitor', %w(investors investments)
    PropagateFundTypeUpJob.perform_later 'Investor', %w(investments)
  end
end
