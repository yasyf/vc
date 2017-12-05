if Rails.env.production? && !Rails.const_defined?('Console')
  AppWarmupJob.perform_later
end