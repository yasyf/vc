class FounderEnhanceJob < ApplicationJob
  include Concerns::Ignorable
  queue_as :now

  def perform(founder_id, augment: false)
    founder = Founder.find(founder_id)

    if augment
      update_location_info founder
      founder.save! if founder.changed?

      augment_with_clearbit founder
      update_location_info founder
      crawl_homepage! founder
    else
      update_location_info founder
    end

    ignore_invalid { founder.save_and_fix_duplicates! }
  end

  private

  def update_location_info(founder)
    founder.city = Geocoder.search(founder.ip_address).first&.city if founder.ip_address.present?
    founder.time_zone = Http::GoogleMaps.new.timezone(founder.city)&.name if founder.city.present?
  end

  def augment_with_clearbit(founder)
    response = Http::Clearbit.new(founder, founder.primary_company).enhance
    return unless response&.person.present?

    founder.city = response.person.geo.city if founder.city.blank?
    founder.time_zone = response.person.time_zone if founder.time_zone.blank?
    founder.bio = response.person.bio if founder.bio.blank?
    founder.homepage = response.person.site if founder.homepage.blank?
    founder.facebook = response.person.facebook.handle if founder.facebook.blank?
    founder.twitter = response.person.twitter.handle if founder.twitter.blank?
    founder.linkedin = response.person.linkedin.handle if founder.linkedin.blank?
    founder.photo = response.person.avatar if founder.photo.blank?
  rescue Http::Clearbit::Error
  end

  def crawl_homepage!(founder)
    body = Http::Fetch.get_one founder.homepage
    unless body.present?
      founder.homepage = nil
      return
    end
    Entity.from_html(body).each do |entity|
      founder.entities << entity unless founder.entities.include?(entity)
    end
  end
end
