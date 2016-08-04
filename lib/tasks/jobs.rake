namespace :jobs do
  [
    'VoteMonitorJob',
    'CacheWarmJob',
    'ApplicationMonitorJob',
    'CardMonitorJob',
  ].each do |klass|
    name = klass.sub('Job', '').underscore
    desc "Run #{klass}"
    task name => :environment do
      klass.constantize.perform_now
    end
  end
end
