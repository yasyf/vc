class Note < ApplicationRecord
  belongs_to :founder
  belongs_to :subject, polymorphic: true

  validates :body, presence: true
end
