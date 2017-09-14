HttpLog.configure do |config|
  config.logger = Rails.logger
  config.compact_log = true
end if Rails.env.development?