class IntroRequest < ApplicationRecord
  TOKEN_MAGIC = "VCWIZ_INTRO_"

  belongs_to :investor
  belongs_to :company
  belongs_to :founder

  validates :investor, presence: true, uniqueness: { scope: [:founder, :company] }
  validates :company, presence: true
  validates :founder, presence: true
  validates :token, presence: true

  before_validation :set_token!, on: :create
  after_commit :send!, on: :create

  def decide!(decision)
    update! accepted: decision
    if decision
      IntroMailer.intro_email(self).deliver_later
    else
      if investor.opted_in?
        IntroMailer.no_intro_email(self).deliver_later
      else
        IntroMailer.no_opt_in_email(self).deliver_later
      end
    end
  end

  def public_token
    "#{TOKEN_MAGIC}#{token}"
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
