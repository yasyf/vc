Warden::Manager.after_set_user do |user, auth, opts|
  next unless user.respond_to?(:logged_in_at)
  if user.logged_in_at.blank? || user.logged_in_at < 1.day.ago
    ip_address = auth.env['HTTP_X_FORWARDED_FOR'].try(:split, ',').try(:first) || auth.env['REMOTE_ADDR']
    user.update! logged_in_at: Time.now, ip_address: ip_address
  end
end
