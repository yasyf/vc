class Email < ApplicationRecord
  belongs_to :founder
  belongs_to :company
  belongs_to :investor
  belongs_to :intro_request

  validates :investor, presence: true
  validates :company, presence: true
  validates :founder, presence: true

  enum direction: %w(incoming outgoing) # from the founder's perspective
end
