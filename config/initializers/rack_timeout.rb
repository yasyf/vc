Rack::Timeout.service_timeout = 20
Rack::Timeout::Logger.disable if Rails.env.development?