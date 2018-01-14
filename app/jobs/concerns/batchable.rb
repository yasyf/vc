module Concerns
  module Batchable
    extend ActiveSupport::Concern

    private

    def run_job_in_batches(klass, job, max_delay: nil, limit_factor: nil, queue: :low)
      max_delay ||= self.class::MAX_DELAY
      limit_factor ||= self.class::LIMIT_FACTOR
      klass.order('RANDOM()').limit(klass.count / limit_factor.to_f).in_batches do |scope|
        scope.pluck(:id).each { |id| job.set(queue: queue, wait: max_delay * rand).perform_later(id) }
      end
    end
  end
end
