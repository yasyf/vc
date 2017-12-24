require_relative './boot'
require_relative './environment'

SitemapGenerator::Sitemap.default_host = "https://#{ENV['MARKETING_DOMAIN']}"
SitemapGenerator::Sitemap.create do
  add external_vcwiz_discover_path, changefreq: :daily, priority: 0.9
  add external_vcwiz_filter_path, priority: 0.7
  add external_vcwiz_search_path, priority: 0.7
  add external_vcwiz_list_path(list: 'most_recent'), changefreq: :daily, priority: 0.6
  add external_vcwiz_list_path(list: 'most_popular_global'), changefreq: :daily, priority: 0.6
  Competitor.locations(nil, nil).each do |city|
    add external_vcwiz_list_path(list: 'most_popular', key: :city, value: city), changefreq: :weekly
  end
  Competitor::INDUSTRIES.each do |industry|
    add external_vcwiz_list_path(list: 'most_recent_in', key: :industry, value: industry), changefreq: :weekly
  end
  Competitor::FUND_TYPES.each do |fund_type|
    add external_vcwiz_list_path(list: 'most_popular_of', key: :fund_type, value: fund_type), changefreq: :weekly
  end
  CompetitorLists::CompanyInvestors.cache_values_span.each do |v|
    add external_vcwiz_list_path(list: 'company_investors', key: :company_id, value: v[:company_id]), changefreq: :weekly
  end
  Investor.in_batches do |scope|
    scope.pluck(:id, :first_name, :last_name).each do |investor|
      add external_vcwiz_investor_path(id: investor.first, slug: "#{investor.second} #{investor.third}".downcase.dasherize), changefreq: :weekly
    end
  end
  Competitor.in_batches do |scope|
    scope.pluck(:id, :name).each do |competitor|
      add external_vcwiz_firm_path(id: competitor.first, slug: investor.last.downcase.dasherize), changefreq: :weekly
    end
  end
end
