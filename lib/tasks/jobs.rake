namespace :jobs do
  desc "Run VoteMonitorJob"
  task vote_monitor: :environment do
    VoteMonitorJob.perform_now
  end
end
