require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  every(1.hour, 'sync.list') { List.sync! }
  every(1.hour, 'sync.company.shallow') { Company.sync!(quiet: false, deep: false) }
  every(1.day, 'sync.company.deep', at: '00:00') { Company.sync!(quiet: false, deep: true) }
  every(1.hour, 'sync.evergreen') { Slack::CollectEvergreensJob.perform_later }

  every(2.weeks, 'cache.warm', at: 'Monday 08:00') { CacheWarmJob.perform_later }

  every(10.minutes, 'pitch.notify') { CompanyPrepareJob.perform_later }

  every(1.day, 'monitor.user', at: '08:00') { UserMonitorJob.perform_later }
  every(1.day, 'monitor.application', at: '08:00') { ApplicationMonitorJob.perform_later }
  every(1.day, 'monitor.card', at: '09:00') { CardMonitorJob.perform_later }
  every(1.minute, 'monitor.vote') { VoteMonitorJob.perform_later }
  every(1.hour, 'monitor.news') { CompanyNewsJob.perform_later }

  every(1.hours, 'user.calendar') { UserCalendarJob.perform_later }

  every(1.day, 'crawl.investors.posts', at: '01:00') { CrawlPostsJob.perform_later }
  every(1.hour, 'crawl.investors.tweets', skip_first_run: true) { CrawlTweetsJob.perform_later }
  every(3.weeks, 'crawl.refresh', at: 'Monday 5:30') { RefreshJob.perform_later }

  every(1.day, 'vctool.industry', at: '00:00') { PropagateIndustryJob.perform_later }
  every(1.hours, 'vctool.investors') { FindInvestorsJob.perform_later }
end
