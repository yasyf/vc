class Company < ActiveRecord::Base
  has_many :votes

  validates :name, presence: true, uniqueness: true
  validates :trello_url, presence: true, uniqueness: true

  def quorum?
    votes.valid(created_at).count >= User.quorum
  end

  def funded?
    quorum? && votes.yes.count > votes.no.count
  end
end
