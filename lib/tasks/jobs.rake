namespace :jobs do
  desc "Run VoteMonitorJob"
  task vote_monitor: :environment do
    VoteMonitorJob.perform_now
  end

  desc "Run CacheWarmJob"
  task cache_warm: :environment do
    CacheWarmJob.perform_now
  end

  desc "Run ApplicationMonitorJob"
  task application_monitor: :environment do
    ApplicationMonitorJob.perform_now
  end
end
