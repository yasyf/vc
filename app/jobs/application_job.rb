class ApplicationJob < ActiveJob::Base
  def self.retry_with_exp_backoff(ex, attempts: 10, queue: :low)
    retry_on ex, wait: :exponentially_longer, queue: queue, attempts: attempts
  end

  # API Errors
  retry_with_exp_backoff Http::AngelList::Errors::APIError
  retry_with_exp_backoff Http::Crunchbase::Errors::APIError
  retry_with_exp_backoff Twitter::Error

  # Timeouts
  retry_with_exp_backoff Timeout::Error
  retry_with_exp_backoff HTTP::TimeoutError

  # Rate Limits
  retry_with_exp_backoff Google::Apis::RateLimitError

  # Retries
  retry_on PG::UniqueViolation
  retry_on ActiveRecord::RecordNotUnique

  # Temporary Failures
  retry_with_exp_backoff Redis::CommandError
  retry_with_exp_backoff SocketError
  retry_with_exp_backoff OpenSSL::SSL::SSLError

  # Irrecoverable
  discard_on Http::Crunchbase::Errors::BadRequest
  discard_on ActiveRecord::RecordNotFound
  discard_on PG::ForeignKeyViolation
end
