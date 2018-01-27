class AppWarmupJob < ApplicationJob
  queue_as :long_now

  def perform(host = ENV['SITE_DOMAIN'])
    3.times do
      sleep 5
      Rails.logger.info "[Warmup] Fetching http://#{host}"
      Http::Fetch.get_one "http://#{host}"
    end
  end
end
