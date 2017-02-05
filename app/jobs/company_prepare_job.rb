class CompanyPrepareJob < ApplicationJob
  queue_as :default

  def perform
    Company.pitch.undecided.each(&:prepare_team!)
  end
end
