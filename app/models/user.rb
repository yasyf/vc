class User < ActiveRecord::Base
  has_many votes

  validates :username, presence: true, uniqueness: true
end
