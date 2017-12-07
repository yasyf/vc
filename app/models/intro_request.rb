class IntroRequest < ApplicationRecord
  include Concerns::Openable
  include Concerns::Tokenable

  TOKEN_MAGIC = 'VCWIZ_INTRO_'
  MAX_IN_FLIGHT = 5

  belongs_to :investor
  belongs_to :company
  belongs_to :founder
  belongs_to :target_investor
  has_one :email

  validates :investor, presence: true, uniqueness: { scope: [:founder, :company] }
  validates :company, presence: true
  validates :founder, presence: true

  validate :limit_outstanding_requests, on: :create

  before_validation :check_opt_out!, on: :create
  after_commit :create_email!, on: :create

  def self.from_target_investor(target_investor)
    where(target_investor: target_investor).first_or_initialize.tap do |intro|
      intro.update_attributes(
        investor: target_investor.investor,
        founder: target_investor.founder,
        company: target_investor.founder.primary_company,
      )
    end
  end

  def decide!(decision)
    update! accepted: decision
    send_decision!
  end

  def send_decision!
    return unless decided?
    if accepted
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
    super options.reverse_merge(methods: [:clicks, :travel_status])
  end

  def send!
    update! pending: false
    if investor.opted_out?
      send_decision!
    else
      target_investor&.intro_requested! self.id
      if investor.opted_in?
        IntroMailer.request_email(self).deliver_later
      else
        IntroMailer.opt_in_email(self).deliver_later
      end
    end
  end

  def start_preview_job!
    IntroRequestPreviewJob.perform_later(self.id)
  end

  private

  def create_email!
    message = IntroMailer.request_preview_email(self)
    Email.create!(
      intro_request: self,
      founder: founder,
      investor: investor,
      company: company,
      direction: :outgoing,
      old_stage: TargetInvestor::RAW_STAGES.keys.index(:added),
      new_stage: TargetInvestor::RAW_STAGES.keys.index(:intro),
      body: message.body,
      subject: message.subject,
    )
  end

  def limit_outstanding_requests
    if self.class.unscoped.where(founder: founder, accepted: nil).count > MAX_IN_FLIGHT - 1
      errors.add(:base, 'too many outstanding requests')
    end
  end

  def check_opt_out!
    self.accepted = false if investor.opted_out?
  end
end
