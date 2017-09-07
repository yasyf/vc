class AddTrackingToIntroRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :intro_requests, :open_city, :string
    add_column :intro_requests, :open_country, :string
    add_column :intro_requests, :open_device_type, :integer
    add_column :intro_requests, :click_domains, :string, array: true, default: []
  end
end
