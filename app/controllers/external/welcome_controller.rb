class External::WelcomeController < External::ApplicationController
  def index
    redirect_to external_vcfinder_root_path
  end
end
