class VoteMonitorJob < ActiveJob::Base
  REMAINING_THRESHOLD = 10.minutes

  queue_as :now

  def perform
    Team.for_each do |team|
      pending = team.companies.undecided.where('pitches.when <= ?', Date.today.in_time_zone(team.time_zone))
      pending.each do |company|
        next unless company.pitch.votes.present?
        time_remaining = team.datetime_now - company.pitch.deadline.to_datetime
        if company.pitch.missing_vote_users.count == 0
          company.pitch.decide!
          company.pitch.notify_team!
          company.card.move_to_post_pitch_list!
        elsif time_remaining <= REMAINING_THRESHOLD && time_remaining >= -REMAINING_THRESHOLD
          warned = company.pitch.warn_team! company.pitch.missing_vote_users, time_remaining
          company.pitch.missing_votes.each { |vote| vote.warn!(time_remaining) } if warned
        end
      end
    end
  end
end
