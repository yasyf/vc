if Rails.env.production?
  Geocoder.configure(
    ip_lookup: :geoip2,
    geoip2: {
      lib: 'hive_geoip2',
      file: ENV['GEOIP_DB_PATH'],
    }
  )
end