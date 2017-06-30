class Pitch < ApplicationRecord
  belongs_to :company

  validates :company, presence: true
  validates :when, presence: true
  validates :cached_funded, inclusion: [true, false, nil]
end
