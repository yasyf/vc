require 'test_helper'

class VoteMonitorJobTest < ActiveJob::TestCase
  VoteMonitorJob.perform_now
end
