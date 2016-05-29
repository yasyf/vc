class VoteMonitorJob < ActiveJob::Base
  DEADLINE = 2.days

  queue_as :default

  def perform(*args)
    pending = Company.where('pitched_at < ?', Time.now - 1.day).where(decision_at: nil)
    deadline = company.pitched_at + DEADLINE
    time_remaining = deadline - Time.now
    pending.each do |company|
      missing_users = company.votes.where(final: false).pluck(:user) - company.votes.final.pluck(:user)
      missing_votes = company.votes.where(final: false).where(user: missing_users)
      if missing_users.count == 0
        company.update! decision_at: Time.now
        company.notify_team!
      elsif time_remaining <= 1.hour
        missing_votes.each { |vote| vote.warn!(time_remaining) }
        company.warn_team!(missing_users, time_remaining)
      end
    end
  end
end
