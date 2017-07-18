class CompanyPrepareJob < ApplicationJob
  queue_as :default

  def perform
    Company.pitched.undecided.each { |c| c.pitch.prepare_team! }
  end
end