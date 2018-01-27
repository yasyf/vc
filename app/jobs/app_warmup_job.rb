class AppWarmupJob < ApplicationJob
  queue_as :long_now

  def perform(host = ENV['SITE_DOMAIN'])
    return unless Rails.env.production?
    url = "http://#{host}/?bypass_force_ssl_for_warmup=1"
    Rails.logger.info "[Warmup] Fetching #{url}"
    5.times do
      5.times { Http::Fetch.get_one url }
      sleep 5
    end
  end
end
