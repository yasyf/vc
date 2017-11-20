class FounderRefreshJob < ApplicationJob
  queue_as :default

  def perform(founder_id)
    founder = Founder.find(founder_id)
    founder.send(:set_response_time!)
  end
end
