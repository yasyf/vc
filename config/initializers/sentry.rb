Raven.configure do |config|
  config.async = lambda { |event|
    SentryJob.perform_later(event.to_hash)
  }

  config.processors -= [Raven::Processor::PostData]
  config.processors -= [Raven::Processor::Cookies]
end
