class FounderEnhanceJob < ApplicationJob
  queue_as :now

  def perform(founder_id)
    founder = Founder.find(founder_id)
    response = Http::Clearbit.new(founder).enhance

    founder.city ||= response.person.geo.city
    founder.time_zone ||= response.person.time_zone
    founder.bio ||= response.person.bio
    founder.homepage ||= response.person.site
    founder.facebook ||= response.person.facebook.handle
    founder.twitter ||= response.person.twitter.handle
    founder.linkedin ||= response.person.linkedin.handle

    founder.city ||= Http::Freegeoip.new(founder.ip_address).locate['city'] if founder.ip_address.present?
    founder.time_zone ||= Http::GoogleMaps.new.timezone(founder.city).name if founder.city.present?
    crawl_homepage! founder

    founder.save! if founder.changed?
    # get entities, also get entities for Investor blog posts, then surface commonalities and tags, then import Alon, then get features
  end

  private

  def crawl_homepage!(founder)
    body = Http::Fetch.get_one founder.homepage
    unless body.present?
      founder.homepage = nil
      return
    end
    founder.entities += Entity.from_html(body)
  end
end
