require 'googlemaps/services/client'
require 'googlemaps/services/geocoding'
require 'googlemaps/services/timezone'

class Http::GoogleMaps
  include ::GoogleMaps::Services
  include Concerns::Cacheable

  def initialize
    @client = GoogleClient.new(key: ENV['GOOGLE_API_KEY'], response_format: :json)
  end

  def geocode(location)
    key_cached(service: :geocode, location: location) do
      get(Geocode).query(address: location)
    end
  end

  def lat_lng(location)
    result = geocode(location).first
    result['geometry']['location'] if result.present?
  end

  def timezone(loc)
    hash = loc.is_a?(String) ? lat_lng(loc) : loc
    return nil unless hash.present?
    location = "#{hash['lat']},#{hash['lng']}"
    tzinfo = key_cached(service: :timezone, location: location) do
      get(Timezone).query(location: location)
    end
    return nil unless tzinfo.present? && tzinfo['timeZoneId'].present?
    ActiveSupport::TimeZone[tzinfo['timeZoneId']]
  end

  private

  def base_cache_key
    'http/google_maps'
  end

  def get(klass)
    name = "@#{klass.name.demodulize.downcase}"
    return instance_variable_get(name) if instance_variable_defined?(name)
    instance_variable_set(name, klass.new(@client))
  end
end