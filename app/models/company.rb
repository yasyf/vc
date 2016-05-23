class Company < ActiveRecord::Base
  has_many :votes

  validates :name, presence: true, uniqueness: true
  validates :trello_url, presence: true, uniqueness: true

  def quorum?(at: Time.now)
    votes.valid(at).count >= User.quorum
  end

  def funded?(at: Time.now)
    quorum?(at) && votes.yes.count > votes.no.count
  end
end
