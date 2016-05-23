class User < ActiveRecord::Base
  QUORUM_PERCENTAGE = 0.6

  has_many :votes

  validates :username, presence: true, uniqueness: true
  validates :active, inclusion: [true, false]

  def self.quorum
    @quorum ||= (where(active: true).count * QUORUM_PERCENTAGE).to_i
  end
end
