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
    investor.email ||= social[:email] if social[:email].present?
    investor.role ||= social[:position] if social[:position].present?
    investor.twitter ||= social[:twitter] if social[:twitter].present?
    investor.linkedin ||= social[:linkedin] if social[:linkedin].present?
    investor.save!
  end

  def augment_with_clearbit(investor)
    response = Http::Clearbit.new(investor, investor.competitor).enhance
    investor.location ||= response.person.geo.city
    investor.time_zone ||= response.person.time_zone
    investor.description ||= response.person.bio
    investor.homepage ||= response.person.site
    investor.facebook ||= response.person.facebook.handle
    investor.twitter ||= response.person.twitter.handle
    investor.linkedin ||= response.person.linkedin.handle
    investor.save!
  rescue Http::Clearbit::Error
  end
end
