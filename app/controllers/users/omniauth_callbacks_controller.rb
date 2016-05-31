module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
        @user = User.from_omniauth(request.env["omniauth.auth"])

        if @user.present?
          set_flash_message :notice, :success, kind: "Google"
          sign_in_and_redirect @user, :event => :authentication
        else
          set_flash_message :alert, :failure, kind: "Google", reason: 'user not found'
          redirect_to root_path
        end
    end

    def failure
      redirect_to root_path
    end
  end
end
