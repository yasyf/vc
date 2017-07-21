class External::WelcomeController < External::ApplicationController
  def index
    redirect_to external_path('vcfinder_root')
  end
end
