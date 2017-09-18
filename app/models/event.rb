class Event < ApplicationRecord
  belongs_to :subject, polymorphic: true

  validates :subject, presence: true
  validates :action, presence: true
end
