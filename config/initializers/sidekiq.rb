require 'sidekiq'

CONNECTION_LIMIT = Rails.env.development? ? 50 : 20

Sidekiq.configure_client do |config|
  config.redis = { size: 1, namespace: 'sidekiq' }
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'sidekiq', size: CONNECTION_LIMIT - (ENV['WEB_CONCURRENCY'].to_i * ENV['MAX_THREADS'].to_i) }
end

Sidekiq.default_worker_options = {
  unique: :until_executing,
  unique_args: ->(args) { [ args.first.except('job_id') ] }
}
