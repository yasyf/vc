class User < ActiveRecord::Base
  QUORUM_PERCENTAGE = 0.6

  has_many :votes

  validates :username, presence: true, uniqueness: true

  scope :inactive, Proc.new { |since| where('inactive_since <= ?', since || Time.now) }
  scope :active, Proc.new { |since| inactive(since).not }

  def self.quorum
    @quorum ||= (active.count * QUORUM_PERCENTAGE).to_i
  end
end
