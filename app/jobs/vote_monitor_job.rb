class VoteMonitorJob < ActiveJob::Base
  REMAINING_THRESHOLD = 10.minutes

  queue_as :default

  def perform
    pending = Company.where('pitch_on <= ?', Date.today).where(decision_at: nil)
    pending.each do |company|
      next unless company.votes.present?
      next unless company.quorum?
      time_remaining = company.team.datetime_now - company.deadline.to_datetime
      if company.missing_vote_users.count == 0
        company.update! decision_at: Time.current, cached_funded: company.funded?
        company.notify_team!
        company.move_to_post_pitch_list!
      elsif time_remaining <= REMAINING_THRESHOLD && time_remaining >= -REMAINING_THRESHOLD
        company.missing_votes.each { |vote| vote.warn!(time_remaining) } if company.warn_team!
      end
    end
  end
end
