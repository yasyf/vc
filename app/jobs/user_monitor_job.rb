class UserMonitorJob < ActiveJob::Base
  INACTIVE_THRESHOLD = 1.month
  VOTE_THRESHOLD = 2.weeks

  queue_as :default

  def perform
    Team.for_each do |team|
      User.active(team).where('logged_in_at < ?', INACTIVE_THRESHOLD.ago).each do |user|
        user.toggle_active! user.logged_in_at
      end
      User
        .active(team)
        .joins(:votes)
        .where('votes.created_at = (SELECT MAX(votes.created_at) FROM votes WHERE votes.user_id = users.id)')
        .where('votes.created_at < ?', VOTE_THRESHOLD.ago)
        .select('users.*, votes.created_at as last_voted_on')
        .each do |user|
          user.toggle_active! user.last_voted_on
        end
    end
  end
end
