Raven.configure do |config|
  config.async = lambda { |event|
    SentryJob.perform_later(event.to_hash, ENV['SENTRY_DSN'])
  }

  config.processors -= [Raven::Processor::PostData]
  config.processors -= [Raven::Processor::Cookies]

  config.excluded_exceptions += %w(
    HTTP::AngelList::Errors::RateLimited
    HTTP::Crunchbase::Errors::RateLimited
    HTTP::Crunchbase::Errors::Timeout
    Sidekiq::Shutdown
    Timeout::Error
  )
end
