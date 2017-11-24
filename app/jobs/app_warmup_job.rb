class AppWarmupJob < ApplicationJob
  queue_as :now

  def perform
    3.times do
      sleep 5
      Http::Fetch.get_one "https://#{ENV['MARKETING_DOMAIN']}"
    end
  end
end
