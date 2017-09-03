class Email < ApplicationRecord
  belongs_to :founder
  belongs_to :company
  belongs_to :investor

  validates :investor, presence: true
  validates :company, presence: true
  validates :founder, presence: true

  enum direction: %w(incoming outgoing) # from the founder's perspective
end
