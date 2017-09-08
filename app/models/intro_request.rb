class IntroRequest < ApplicationRecord
  TOKEN_MAGIC = "VCWIZ_INTRO_"
  DEVICE_TYPES = %w(desktop mobile tablet other unknown)

  belongs_to :investor
  belongs_to :company
  belongs_to :founder

  validates :investor, presence: true, uniqueness: { scope: [:founder, :company] }
  validates :company, presence: true
  validates :founder, presence: true
  validates :token, presence: true

  enum open_device_type: DEVICE_TYPES

  before_validation :set_token!, on: :create
  after_commit :send!, on: :create

  def decide!(decision)
    update! accepted: decision
    if decision
      IntroMailer.intro_email(self).deliver_later
    else
      if investor.opted_in?
        IntroMailer.no_intro_email(self).deliver_later
        IntroMailer.reason_email(self).deliver_later
      else
        IntroMailer.no_opt_in_email(self).deliver_later
      end
    end
  end

  def decided?
    accepted != nil
  end

  def public_token
    "#{TOKEN_MAGIC}#{token}"
  end

  def add_domain!(url)
    self.click_domains << URI.parse(url).host
    save!
  end

  def travel_status
    if open_country.blank?
      nil
    elsif open_country != 'US'
      :pleasure_traveling
    else
      investor.travel_status open_city
    end
  end

  def clicked?(url)
    ((URI.parse(url).host rescue nil) || url).in? click_domains
  end

  %w(twitter linkedin).each do |s|
    define_method "clicked_#{s}?" do
      clicked? "www.#{s}.com"
    end
  end

  def clicked_website?
    company.domain.present? ? clicked?(company.domain) : false
  end

  def clicked_deck?
    pitch_deck.present? ? clicked?(pitch_deck) : false
  end

  def clicks
    %w(twitter linkedin website deck).map { |s| [s, send("clicked_#{s}?")] }.to_h
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:id, :opened_at, :open_city, :accepted, :reason], methods: [:clicks, :travel_status])
  end

  private

  def send!
    if investor.opted_in == false
      decide! false
    elsif investor.opted_in?
      IntroMailer.request_email(self).deliver_later
    else
      IntroMailer.opt_in_email(self).deliver_later
    end
  end

  def set_token!
    self.token ||= SecureRandom.hex.first(10).upcase
  end
end
