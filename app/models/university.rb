class University < ApplicationRecord
  has_many :investors

  validates :name, presence: true

  def self.from_name(name)
    where(name: name).first_or_create!
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:name])
  end
end
