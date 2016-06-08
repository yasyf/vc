class VoteMonitorJob < ActiveJob::Base
  THRESHOLD = 1.hour

  queue_as :default

  def perform
    pending = Company.where('pitch_on < ?', Time.now - 1.day).where(decision_at: nil)
    pending.each do |company|
      time_remaining = (DateTime.now - company.deadline.to_datetime).days
      missing_users = company.votes.where(final: false).map(&:user) - company.votes.final.map(&:user)
      missing_votes = company.votes.where(final: false).where(user: missing_users)
      if missing_users.count == 0
        company.update! decision_at: Time.now
        company.notify_team!
      elsif time_remaining <= THRESHOLD && time_remaining >= -THRESHOLD
        missing_votes.each { |vote| vote.warn!(time_remaining) }
        company.warn_team!(missing_users, time_remaining)
      end
    end
  end
end
