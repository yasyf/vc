class AppWarmupJob < ApplicationJob
  queue_as :long_now

  def perform(host = ENV['SITE_DOMAIN'])
    return unless Rails.env.production?
    url = "http://#{host}/?bypass_force_ssl_for_warmup=1"
    3.times do
      sleep 5
      Rails.logger.info "[Warmup] Fetching #{url}"
      Http::Fetch.get_one url
    end
  end
end
