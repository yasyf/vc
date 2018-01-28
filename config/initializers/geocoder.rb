if Rails.env.production?
  Geocoder.configure(
    cache: Redis.new(url: ENV['REDIS_CACHE_URL']),
    timeout: 1,
    ip_lookup: ENV['MAXMIND_KEY'].present? ? :maxmind_geoip2 : :geoip2,
    geoip2: {
      lib: 'hive_geoip2',
      file: ENV['GEOIP_DB_PATH'],
    },
    maxmind_geoip2: {
      service: :city,
      basic_auth: { user: ENV['MAXMIND_USER'], password: ENV['MAXMIND_KEY'] }
    }
  )
end