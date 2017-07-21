class WelcomeController < ApplicationController
  def index
    if internal?
      redirect_to internal_root_path
    else
      redirect_to external_root_path
    end
  end
end
