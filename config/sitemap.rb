require_relative './boot'
require_relative './environment'

SitemapGenerator::Sitemap.default_host = "https://#{ENV['MARKETING_DOMAIN']}"
SitemapGenerator::Sitemap.create do
  add external_vcwiz_discover_path, changefreq: :daily, priority: 0.9
  add external_vcwiz_filter_path
  add external_vcwiz_search_path
  add external_vcwiz_list_path(list: 'most_recent'), changefreq: :daily
  add external_vcwiz_list_path(list: 'most_popular_global'), changefreq: :daily
  Competitor.locations(nil, nil).each do |city|
    add external_vcwiz_cached_list_path(list: 'most_popular_global', key: :city, value: city), changefreq: :weekly
  end
  Competitor::INDUSTRIES.each do |industry|
    add external_vcwiz_cached_list_path(list: 'most_recent_in', key: :industry, value: industry), changefreq: :weekly
  end
  Competitor::FUND_TYPES.each do |fund_type|
    add external_vcwiz_cached_list_path(list: 'most_popular_of', key: :fund_type, value: fund_type), changefreq: :weekly
  end
end
