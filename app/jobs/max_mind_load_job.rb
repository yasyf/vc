class MaxMindLoadJob < ApplicationJob
  queue_as :low

  def perform
    `rake geocoder:maxmind:geolite:load PACKAGE=city`
  end
end
