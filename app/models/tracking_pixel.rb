class TrackingPixel < ApplicationRecord
  include Concerns::Openable
  include Concerns::Tokenable

  belongs_to :email
  has_one :founder, through: :email
  has_one :investor, through: :email
  has_one :intro_request, through: :email

  validates :email, presence: true

  def target_investor
    @target_investor ||= TargetInvestor.where(founder: self.founder, investor: self.investor).first
  end

  def ip_address=(ip_address)
    location = Geocoder.search(ip_address).first
    self.open_city = location&.city
    self.open_country = location&.country_code
  end

  def user_agent=(user_agent)
    browser = Browser.new(user_agent, accept_language: 'en-us')
    self.open_device_type = if browser.device.mobile?
      :mobile
    elsif browser.device.tablet?
      :tablet
    elsif browser.platform.mac? || browser.platform.linux? || browser.platform.windows?
      :desktop
    elsif browser.platform.other?
      :other
    else
      :unknown
    end
  end
end
