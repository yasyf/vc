class External::WelcomeController < External::ApplicationController
  def index
    redirect_to external_path('vcwiz_root')
  end
end
