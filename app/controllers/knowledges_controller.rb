class KnowledgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @knowledges = Knowledge.all.order(created_at: :desc)
  end
end
