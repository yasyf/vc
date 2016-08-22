class WelcomeController < ApplicationController
  include Concerns::Slackable

  def index
    if user_signed_in?
      if Company.pitch.undecided.count > 0
        redirect_to controller: 'companies', action: 'voting'
      else
        redirect_to controller: 'companies', action: 'index'
      end
    end
  end

  def send_slack_feedback
    message = "<@#{params[:bot]}>: <@#{current_user.slack_id}> found that annoying!"
    slack_send! params[:channel], message
    flash[:success] = 'Thanks for your feedback!'
    redirect_to root_path
  end
end
