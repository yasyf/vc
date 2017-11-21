class CrunchbasePullJob < ApplicationJob
  URL = 'https://api.crunchbase.com/v3.1/csv_export/csv_export.tar.gz'

  queue_as :low

  def perform
    url = "#{URL}?user_key=#{ENV['CB_API_KEY'].split(',').first}"
    path = Importers::Base.new(url).filename
    parent = File.dirname(path)
    system("tar -xvzf #{path} -C #{parent}")
    Importers::External::Competitors.new(File.join(parent, 'investors.csv')).sync!(async: false)
    Importers::External::Companies.new(File.join(parent, 'organizations.csv')).sync!(async: false)
  end
end
