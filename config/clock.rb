require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  every(1.hour, 'sync.list') { List.sync! }
  every(5.minutes, 'sync.company') { Company.sync!(quiet: false) }
  every(1.hour, 'sync.evergreen') { Slack::CollectEvergreensJob.perform_later }

  every(1.hour, 'cache.warm') { CacheWarmJob.perform_later }

  every(10.minutes, 'pitch.notify') { CompanyPrepareJob.perform_later }

  every(1.day, 'monitor.application') { ApplicationMonitorJob.perform_later }
  every(1.day, 'monitor.card') { CardMonitorJob.perform_later }
  every(1.minute, 'monitor.vote') { VoteMonitorJob.perform_later }
end
