class WelcomeController < ApplicationController
  def index
    redirect_to controller: 'companies' if user_signed_in?
  end
end
