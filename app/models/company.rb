class Company < ActiveRecord::Base
  include Concerns::Slackable

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
    not_s = funded? ? '' : ' not'
    yes_percentage = votes.count > 0 ? stats[:yes_votes].to_f / votes.count : 0
    percentage_s = "#{(yes_percentage * 100).round(0)}\%"
    message = "\nBoston *will#{not_s}* be funding _#{name}_!\n"
    message << "#{percentage_s} voted to fund, with #{stats[:yes_votes]} in favor and #{stats[:no_votes]} against.\n"
    message << stats[:averages].map { |met, val| "*#{met.titleize}*: #{val}" }.join(' | ')
    slack_send! ENV['SLACK_CHANNEL'], message, notify: true
  end

  def self.sync!
    TrelloLib.new.sync do |card_data|
      company = Company.where(trello_id: card_data[:trello_id]).first_or_create
      company.assign_attributes card_data
      company.save! if company.changed?
    end
  end
end
