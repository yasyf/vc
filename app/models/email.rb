class Email < ApplicationRecord
  belongs_to :founder, touch: true
  belongs_to :company
  belongs_to :investor
  belongs_to :intro_request
  has_one :tracking_pixel

  validates :investor, presence: true
  validates :company, presence: true
  validates :founder, presence: true
  validates :email_id, uniqueness: { allow_nil: true }

  enum direction: %w(incoming outgoing) # from the founder's perspective

  scope :after, Proc.new { |email| where('created_at > ?', email.created_at) }

  def tracking_pixel!
    tracking_pixel || create_tracking_pixel
  end
end
