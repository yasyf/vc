class WelcomeController < ApplicationController
  def index
    if internal_user_signed_in?
      redirect_to internal_path('root')
    else
      redirect_to external_path('root')
    end
  end
end
