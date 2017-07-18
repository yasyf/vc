Warden::Manager.after_set_user do |user, auth, opts|
  return unless user.respond_to?(:logged_in_at)
  if user.logged_in_at.blank? || user.logged_in_at < 1.day.ago
    user.update! logged_in_at: Time.now
  end
end
