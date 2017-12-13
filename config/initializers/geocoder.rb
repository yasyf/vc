if Rails.env.production?
  Geocoder.configure(
    cache: Redis.new(url: ENV['REDIS_CACHE_URL']),
    ip_lookup: :geoip2,
    geoip2: {
      lib: 'hive_geoip2',
      file: ENV['GEOIP_DB_PATH'],
    }
  )
end