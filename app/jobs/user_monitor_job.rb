class UserMonitorJob < ActiveJob::Base
  INACTIVE_THRESHOLD = 1.month

  queue_as :default

  def perform
    Team.each do |team|
      User.active(team).where('logged_in_at < ?', INACTIVE_THRESHOLD.ago).each do |user|
        user.toggle_active! user.logged_in_at
      end
    end
  end
end
