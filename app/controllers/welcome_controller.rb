class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      if Company.pitch.undecided.count > 0
        redirect_to controller: 'companies', action: 'voting'
      else
        redirect_to controller: 'companies', action: 'index'
      end
    end
  end
end
