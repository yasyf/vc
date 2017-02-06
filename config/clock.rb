require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  every(1.hour, 'sync.list') { List.sync! }
  every(15.minutes, 'sync.company.shallow') { Company.sync!(quiet: false, deep: false) }
  every(6.hour, 'sync.company.deep') { Company.sync!(quiet: false, deep: true) }
  every(1.hour, 'sync.evergreen') { Slack::CollectEvergreensJob.perform_later }

  every(1.hour, 'cache.warm') { CacheWarmJob.perform_later }

  every(10.minutes, 'pitch.notify') { CompanyPrepareJob.perform_later }

  every(1.day, 'monitor.application', at: '08:00') { ApplicationMonitorJob.perform_later }
  every(1.day, 'monitor.card', at: '09:00') { CardMonitorJob.perform_later }
  every(1.minute, 'monitor.vote') { VoteMonitorJob.perform_later }
  every(1.hour, 'monitor.news') { CompanyNewsJob.perform_later }
end
