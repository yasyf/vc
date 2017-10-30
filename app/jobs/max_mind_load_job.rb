class MaxMindLoadJob < ApplicationJob
  queue_as :default

  def perform
    `rake geocoder:maxmind:geolite:load PACKAGE=city`
  end
end
