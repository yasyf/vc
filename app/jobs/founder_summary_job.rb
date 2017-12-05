class FounderSummaryJob < ApplicationJob
  queue_as :low

  def perform
    Founder.active.select('id').find_each do |founder|
      SummaryMailer.weekly_founder_email(founder).deliver_later
    end
  end
end
