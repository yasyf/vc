class Company < ActiveRecord::Base
  has_many :votes

  validates :name, presence: true, uniqueness: true
  validates :trello_url, presence: true, uniqueness: true
end
