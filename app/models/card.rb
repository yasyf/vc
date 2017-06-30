class Card < ApplicationRecord
  belongs_to :list
  belongs_to :company

  validates :company, presence: true
  validates :list, presence: true
  validates :trello_id, presence: true, uniqueness: true
end
