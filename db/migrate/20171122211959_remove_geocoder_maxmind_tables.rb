class RemoveGeocoderMaxmindTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :maxmind_geolite_city_location
    drop_table :maxmind_geolite_city_blocks
  end
end
