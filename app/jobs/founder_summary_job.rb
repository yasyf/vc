class FounderSummaryJob < ApplicationJob
  queue_as :long

  def perform
    Founder.active.find_each do |founder|
      next if founder.unsubscribed?
      SummaryMailer.weekly_founder_email(founder).deliver_later
    end
  end
end
