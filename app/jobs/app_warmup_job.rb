class AppWarmupJob < ApplicationJob
  queue_as :long_now

  def perform
    3.times do
      sleep 5
      Http::Fetch.get_one "https://#{ENV['SITE_DOMAIN']}"
    end
  end
end
