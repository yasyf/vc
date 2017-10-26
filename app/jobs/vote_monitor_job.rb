class VoteMonitorJob < ActiveJob::Base
  REMAINING_THRESHOLD = 6.hours

  queue_as :now

  def perform
    Team.for_each do |team|
      pending = team.companies.undecided.where('pitches.when <= ?', Date.today.in_time_zone(team.time_zone))
      pending.each do |company|
        next unless company.pitch.votes.present?
        time_remaining = company.pitch.deadline.to_datetime - team.datetime_now
        close_to_deadline = time_remaining <= REMAINING_THRESHOLD
        if company.pitch.missing_vote_users.count == 0 && (company.pitch.has_quorum? || close_to_deadline)
          company.pitch.decide!
          company.pitch.notify_team!
          company.pitch.card.move_to_post_pitch_list!
        elsif close_to_deadline
          warned = company.pitch.warn_team! company.pitch.missing_vote_users, time_remaining
          company.pitch.missing_votes.each { |vote| vote.warn!(time_remaining) } if warned
        end
      end
    end
  end
end
