class User < ActiveRecord::Base
  has_many :votes

  validates :username, presence: true, uniqueness: true
  validates :active, inclusion: [true, false]
end
