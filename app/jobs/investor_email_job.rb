class InvestorEmailJob < ApplicationJob
  THRESHOLD = 1.month

  queue_as :default

  def perform(investor_id)
    investor = Investor.find(investor_id)
    return if investor.verified?
    return if investor.last_fetched && investor.last_fetched > THRESHOLD.ago
    return unless investor.email.blank?
    investor.update! last_fetched: DateTime.now
    augment_with_hunter investor
    return unless investor.email.blank?
    augment_with_clearbit investor
  end

  def augment_with_hunter(investor)
    social = Http::Hunter.new(investor, investor.competitor).social&.with_indifferent_access
    return unless social.present?
    investor.email = social[:email] if social[:email].present? && investor.email.blank?
    investor.role = social[:position] if social[:position].present? && investor.role.blank?
    investor.twitter = social[:twitter] if social[:twitter].present? && investor.twitter.blank?
    investor.linkedin = social[:linkedin] if social[:linkedin].present? && investor.linkedin.blank?
    investor.save!
  end

  def augment_with_clearbit(investor)
    response = Http::Clearbit.new(investor, investor.competitor).enhance
    investor.location = response.person.geo.city if investor.location.blank?
    investor.time_zone = response.person.time_zone if investor.time_zone.blank?
    investor.description = response.person.bio if investor.description.blank?
    investor.homepage = response.person.site if investor.homepage.blank?
    investor.facebook = response.person.facebook.handle if investor.facebook.blank?
    investor.twitter = response.person.twitter.handle if investor.twitter.blank?
    investor.linkedin = response.person.linkedin.handle if investor.linkedin.blank?
    investor.save!
  rescue Http::Clearbit::Error
  end
end
