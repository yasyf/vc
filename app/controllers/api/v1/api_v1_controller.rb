module Api
  module V1
    class ApiV1Controller < ApplicationController
      private

      def authenticate_api_user!
        (user_signed_in? && authenticate_user!) || authenticate_or_request_with_http_token do |token, options|
          email, token = token.split(':')
          user = User.from_email(email)
          if user && Devise.secure_compare(user.authentication_token, token)
            sign_in user, store: false
          end
        end
      end
    end
  end
end
