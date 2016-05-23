class Company < ActiveRecord::Base
  has_many :votes

  validates :name, presence: true, uniqueness: true
  validates :trello_url, presence: true, uniqueness: true

  scope :pitch, -> { where('pitch_on IS NOT NULL') }

  def quorum?
    votes.valid(pitch_on || created_at).count >= User.quorum
  end

  def funded?
    pitch_on.present? && quorum? && votes.yes.count > votes.no.count
  end

  def stats
    {
      yes_votes: votes.yes.count,
      no_votes: votes.no.count,
      averages: Votes.metrics(votes)
    }
  end
end
