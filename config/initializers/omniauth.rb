Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.application.drfvote?
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
      hd: ENV['DOMAIN'], scope: 'userinfo.email,userinfo.profile,calendar.readonly,drive',
      access_type: 'offline', prompt: 'consent', name: 'google_internal', callback_path: '/auth/create'
  end

  if Rails.application.vcwiz?
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], name: 'google_external',
      scope: 'userinfo.email,userinfo.profile', callback_path: '/auth/create', access_type: 'offline'

    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], name: 'gmail',
      scope: 'gmail.readonly', access_type: 'offline', prompt: 'consent', include_granted_scopes: true, callback_path: '/auth/enhance'
  end
end