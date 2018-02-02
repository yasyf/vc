require 'sidekiq'

CLIENT_SIZE = (ENV['SIDEKIQ_POOL'] || 5).to_i
CONNECTION_LIMIT = (ENV['DATABASE_POOL'] || 50).to_i - CLIENT_SIZE - 2

Sidekiq.configure_client do |config|
  config.redis = { size: CLIENT_SIZE }
end

Sidekiq.configure_server do |config|
  config.redis = { size: CONNECTION_LIMIT - (ENV['WEB_CONCURRENCY'].to_i * ENV['MAX_THREADS'].to_i) }
end