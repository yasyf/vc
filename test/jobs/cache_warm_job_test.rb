require 'test_helper'

class CacheWarmJobTest < ActiveJob::TestCase
  CacheWarmJob.perform_now
end
