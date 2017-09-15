require 'sidekiq'

CLIENT_SIZE = 5
CONNECTION_LIMIT = 40 - CLIENT_SIZE - 2

Sidekiq.configure_client do |config|
  config.redis = { size: 5, namespace: 'sidekiq' }
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'sidekiq', size: CONNECTION_LIMIT - (ENV['WEB_CONCURRENCY'].to_i * ENV['MAX_THREADS'].to_i) }
end

Sidekiq.default_worker_options = {
  unique: :until_executing,
  unique_args: ->(args) { [ args.first.except('job_id') ] }
}
