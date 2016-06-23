class Company < ActiveRecord::Base
  include Concerns::Cacheable

  has_many :votes
  belongs_to :list

  validates :name, presence: true
  validates :trello_id, presence: true, uniqueness: true

  scope :pitch, -> { where('pitch_on IS NOT NULL') }
  scope :undecided, -> { where(decision_at: nil) }

  def deadline
    super || pitch_on + 2.days if pitch_on.present?
  end

  def pitched?
    pitch_on.present? && pitch_on < Time.now
  end

  def past_deadline?
    pitched? && (decision_at.present? || deadline < Time.now)
  end

  def quorum?
    cached { pitch_on.present? && votes.valid(pitch_on).count >= User.quorum(pitch_on) }
  end

  def funded?
    cached { quorum? && votes.yes.count > votes.no.count }
  end

  def user_votes(user)
    votes.where(user: user).order(created_at: :desc)
  end

  def stats
    cached do
      {
        yes_votes: votes.yes.count,
        no_votes: votes.no.count,
        required_votes: User.quorum(pitch_on),
        averages: Vote.metrics(votes.final)
      }.with_indifferent_access
    end
  end

  def partner_initials
    cached { trello_card.members.map(&:initials).compact }
  end

  def notify_team!
    VoteMailer.email_and_slack!(:funding_decision_email, nil, self)
  end

  def warn_team!(missing_users, time_remaining)
    VoteMailer.email_and_slack!(:vote_warning_team_email, nil, missing_users, self, time_remaining.to_i)
  end

  def move_to_post_pitch_list!
    list = funded? ? List.funded : List.passed
    trello_card.move_to_list list.trello_id
    update! list: list

    trello_card.name = name
    trello_card.save
  end

  def self.sync!(disable_notifications: false)
    Importers::Trello.new.sync! do |card_data|
      list = List.where(trello_id: card_data[:trello_list_id]).first!
      company = Company.where(trello_id: card_data[:trello_id]).first_or_create
      company.assign_attributes card_data
      company.decision_at ||= Time.now if disable_notifications && company.pitch_on == nil
      if company.list.present? && company.list != list
        LoggedEvent.log! :company_list_changed, company, notify: 0
      end
      company.list = list
      company.save! if company.changed?
    end
  end

  private

  def trello_card
    @trello_card ||= Trello::Card.find trello_id
  end
end
