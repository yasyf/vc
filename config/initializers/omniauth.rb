module OmniAuth::Strategies
  class GoogleInternal < GoogleOauth2
    def name
      :google_internal
    end
  end

  class GoogleExternal < GoogleOauth2
    def name
      :google_external
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.application.drfvote?
    provider :google_internal, ENV['INTERNAL_GOOGLE_CLIENT_ID'], ENV['INTERNAL_GOOGLE_CLIENT_SECRET'],
      hd: ENV['DOMAIN'], scope: 'userinfo.email,userinfo.profile,calendar.readonly,drive',
      access_type: 'offline', prompt: 'consent', callback_path: '/auth/callback'
  end

  if Rails.application.vcwiz?
    provider :google_external, ENV['EXTERNAL_GOOGLE_CLIENT_ID'], ENV['EXTERNAL_GOOGLE_CLIENT_SECRET'],
      scope: 'userinfo.email,userinfo.profile', callback_path: '/auth/callback'
  end
end