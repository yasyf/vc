class Company < ActiveRecord::Base
  has_many :votes

  validates :name, presence: true
  validates :trello_id, presence: true, uniqueness: true

  scope :pitch, -> { where('pitch_on IS NOT NULL') }

  def quorum?
    votes.valid(pitch_on || created_at).count >= User.quorum
  end

  def funded?
    pitch_on.present? && quorum? && votes.yes.count > votes.no.count
  end

  def stats
    @stats ||= {
      yes_votes: votes.yes.count,
      no_votes: votes.no.count,
      averages: Vote.metrics(votes)
    }
  end

  def notify_team!
    VoteMailer.email_and_slack!(:funding_decision_email, nil, self)
  end

  def self.sync!(disable_notifications: false)
    TrelloLib.new.sync do |card_data|
      company = Company.where(trello_id: card_data[:trello_id]).first_or_create
      company.assign_attributes card_data
      company.decision_at ||= Time.now if disable_notifications && company.pitch_on == nil
      company.save! if company.changed?
    end
  end
end
