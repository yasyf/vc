class CompanyPrepareJob < ApplicationJob
  queue_as :default

  def perform
    Company.pitched.undecided.each(&:prepare_team!)
  end
end
