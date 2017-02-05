require 'test_helper'

class CompanyPrepareJobTest < ActiveJob::TestCase
  CompanyPrepareJob.perform_now
end
