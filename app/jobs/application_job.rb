class ApplicationJob < ActiveJob::Base
  def self.retry_with_exp_backoff(ex, attempts: 10, queue: :low)
    retry_on ex, wait: :exponentially_longer, queue: queue, attempts: attempts
  end

  # API Errors
  retry_with_exp_backoff Http::AngelList::Errors::APIError
  retry_with_exp_backoff Http::Crunchbase::Errors::APIError
  retry_with_exp_backoff Twitter::Error::ServerError

  # Timeouts
  retry_with_exp_backoff Net::OpenTimeout
  retry_with_exp_backoff Net::ReadTimeout

  # Temporary Failures
  retry_with_exp_backoff Redis::CommandError

  # Irrecoverable
  discard_on Http::Crunchbase::Errors::BadRequest
  discard_on ActiveRecord::RecordNotFound
  discard_on PG::ForeignKeyViolation
end
