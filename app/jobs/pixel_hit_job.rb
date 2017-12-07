class PixelHitJob < ApplicationJob
  queue_as :default

  def perform(pixel_id, datetime, ip_address, user_agent)
    pixel = TrackingPixel.find(pixel_id)
    pixel.opened_at = DateTime.parse(datetime)
    pixel.ip_address = ip_address
    pixel.user_agent = user_agent
    pixel.save!
  end
end
