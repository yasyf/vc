if Rails.env.production?
  AppWarmupJob.perform_later
end