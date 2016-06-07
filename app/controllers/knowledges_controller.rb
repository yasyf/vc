class KnowledgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @knowledges = Knowledge.all
  end
end
