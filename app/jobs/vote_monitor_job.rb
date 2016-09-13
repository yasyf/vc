class VoteMonitorJob < ActiveJob::Base
  REQUIRED_AGE = 1.hour
  REMAINING_THRESHOLD = 1.hour

  queue_as :default

  def perform
    pending = Company.where('pitch_on < ?', Time.now).where(decision_at: nil)
    pending.each do |company|
      next unless company.votes.present?
      next if company.votes.order(created_at: :asc).first.created_at + REQUIRED_AGE > Time.now
      next unless company.quorum?
      time_remaining = (DateTime.now - company.deadline.to_datetime).days
      if company.missing_vote_users.count == 0
        company.update! decision_at: Time.now
        company.notify_team!
        company.move_to_post_pitch_list!
      elsif time_remaining <= REMAINING_THRESHOLD && time_remaining >= -REMAINING_THRESHOLD
        company.missing_votes.each { |vote| vote.warn!(time_remaining) }
        company.warn_team!(missing_users, time_remaining)
      end
    end
  end
end
