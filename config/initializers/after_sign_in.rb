Warden::Manager.after_set_user do |user, auth, opts|
  next unless user.respond_to?(:logged_in_at)
  if user.logged_in_at.blank? || user.logged_in_at < 1.day.ago
    ip_address = Util.ip_address auth.env
    user.update! logged_in_at: Time.now, ip_address: ip_address
    user.try(:session_refreshed!)
  end
end
