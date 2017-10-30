class External::WelcomeController < External::ApplicationController
  def index
    redirect_to external_vcwiz_root_path
  end
end
