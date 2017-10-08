require_relative './boot'
require_relative './environment'

Zhong.redis = Redis.new(url: ENV['HEROKU_REDIS_COPPER_URL'])

Zhong.schedule do
  category 'sync' do
    every(1.hour, 'list') { List.sync! }
    every(1.hour, 'company.shallow') { Company.sync!(quiet: false, deep: false) }
    every(1.day, 'company.deep', at: '00:00') { Company.sync!(quiet: false, deep: true) }
    every(1.hour, 'evergreen') { Slack::CollectEvergreensJob.perform_later }
  end

  category 'cache' do
    every(2.weeks, 'warm', at: 'Monday 08:00') { CacheWarmJob.perform_later }
  end

  category 'pitch' do
    every(10.minutes, 'notify') { CompanyPrepareJob.perform_later }
  end

  category 'monitor' do
    every(1.day, 'user', at: '08:00') { UserMonitorJob.perform_later }
    every(1.day, 'application', at: '08:00') { ApplicationMonitorJob.perform_later }
    every(1.day, 'card', at: '09:00') { CardMonitorJob.perform_later }
    every(1.minute, 'vote') { VoteMonitorJob.perform_later }
    every(1.hour, 'news') { CompanyNewsJob.perform_later }
  end

  category 'users' do
    every(1.hours, 'calendar') { UserCalendarJob.perform_later }
  end

  category 'crawl' do
    every(4.days, 'investors.posts', at: '01:00') { CrawlPostsJob.perform_later }
    every(12.hours, 'investors.tweets', skip_first_run: true) { CrawlTweetsJob.perform_later }
    every((1.5).weeks, 'refresh', at: 'Monday 5:30') { RefreshJob.perform_later }
  end

  category 'vcwiz' do
    every(1.day, 'industry', at: '00:00') { PropagateIndustryJob.perform_later }
    every(1.hours, 'investors') { FindInvestorsJob.perform_later }
  end
end