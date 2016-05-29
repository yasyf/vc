class VoteMonitorJob < ActiveJob::Base
  DEADLINE = 2.days

  queue_as :default

  def perform(*args)
    pending = Company.where('pitched_at < ?', Time.now - 1.day).where(decision_at: nil)
    deadline = company.pitched_at + DEADLINE
    pending.each do |company|
      missing_users = company.votes.where(final: false).pluck(:user) - company.votes.final.pluck(:user)
      missing_votes = company.votes.where(final: false).where(user: missing_users)
      if missing_users.count == 0
        Company.notify_team!
      elsif deadline < Time.now
        missing_votes.each(&:scold!)
      elsif (deadline - Time.now) <= 1.hour
        missing_votes.each(&:warn!)
        Company.warn_team!
      end
    end
  end
end
