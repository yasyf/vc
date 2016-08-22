class Company < ActiveRecord::Base
  include Concerns::Cacheable
  include ActionView::Helpers::NumberHelper

  has_many :votes
  belongs_to :list
  belongs_to :team
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :trello_id, presence: true, uniqueness: true
  validates :domain, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }

  scope :pitch, -> { where('pitch_on IS NOT NULL') }
  scope :decided, -> { where.not(decision_at: nil) }
  scope :undecided, -> { where(decision_at: nil) }
  scope :search, Proc.new { |term| where('name ILIKE ?', "%#{term}%") if term.present? }

  before_create :set_snapshot_link
  before_create :set_crunchbase_id
  after_create :add_to_wit

  def domain=(domain)
    super begin
      URI.parse(domain).host
    rescue URI::InvalidURIError
      domain
    end
  end

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
    override_quorum? || cache_for_a_hour { pitch_on.present? && votes.valid(team, pitch_on).count >= User.quorum(team, pitch_on) }
  end

  def funded?
    cache_for_a_hour { quorum? && yes_votes > no_votes }
  end

  def vote_for_user(user)
    user_votes(user).final.first
  end

  def stats
    cached do
      {
        yes_votes: yes_votes,
        no_votes: no_votes,
        required_votes: User.quorum(team, pitch_on),
        averages: Vote.metrics(votes.final)
      }.with_indifferent_access
    end
  end

  def partner_initials
    cached { users.map(&:initials) }
  end

  def notify_team!
    VoteMailer.email_and_slack!(:funding_decision_email, team, self)
  end

  def warn_team!(missing_users, time_remaining)
    VoteMailer.email_and_slack!(:vote_warning_team_email, team, missing_users, self, time_remaining.to_i)
  end

  def move_to_list!(list)
    trello_card.move_to_list list.trello_id
    trello_card.save

    update! list: list
  end

  def move_to_rejected_list!
    list = pitched? ? team.lists.passed : team.lists.rejected
    move_to_list! list
  end

  def move_to_post_pitch_list!
    list = funded? ? team.lists.funded : team.lists.passed
    move_to_list! list

    trello_card.name = name
    trello_card.save
  end

  def self.sync!(disable_notifications: false)
    Team.for_each do |team|
      Importers::Trello.new(team).sync! do |card_data|
        users = card_data.delete(:members).map do |member|
          if member.email.present?
            User.from_email member.email
          else
            User.where(cached_name: member.full_name).first
          end.tap do |user|
            if user.present?
              user.team = team
              user.trello_id = member.id
              user.save! if user.changed?
            end
          end
        end.compact
        list = List.where(trello_id: card_data.delete(:trello_list_id)).first!

        company = Company.where(trello_id: card_data[:trello_id]).first_or_create
        company.assign_attributes card_data
        company.decision_at ||= Time.now if disable_notifications && company.pitch_on == nil
        if company.list.present? && company.list != list
          LoggedEvent.log! :company_list_changed, company,
            notify: 0, data: { from: company.list.trello_id, to: list.trello_id, date: Date.today }
        end
        company.team = team
        company.list = list
        company.users = users
        company.set_snapshot_link
        company.set_crunchbase_id
        company.save! if company.changed?
      end
    end
  end

  def user_votes(user)
    votes.where(user: user).order(created_at: :desc)
  end

  def trello_url
    "https://trello.com/c/#{trello_id}"
  end

  def description
    cache_for_a_hour { crunchbase_org.description }
  end

  def rdv_funded?
    cache_for_a_hour { crunchbase_org.has_investor?('Rough Draft Ventures') || Http::Rdv.new.invested?(name) }
  end

  def capital_raised
    amount = cache_for_a_hour { [crunchbase_org.total_funding || 0, funded? ? 20_000 : 0].max }
    number_to_human(amount, locale: :money)
  end

  def add_user(user)
    trello_card.add_member user.trello_user
    trello_card.save
  end

  def as_json(options = {})
    options.reverse_merge!(
      methods: [:trello_url, :stats, :capital_raised, :description],
      only: [:id, :name, :trello_id, :snapshot_link, :domain]
    )
    super(options).merge(
      pitch_on: pitch_on&.to_time&.to_i,
      funded: funded?,
      rdv_funded: rdv_funded?,
      past_deadline: past_deadline?,
      pitched: pitched?,
      partners: users.map { |user| { name: user.name, slack_id: user.slack_id }  }
    )
  end

  private

  def set_snapshot_link
    self.snapshot_link ||= GoogleApi::Drive.new.find("#{name.gsub(/['"]/, '')} Snapshot")&.web_view_link
  end

  def set_crunchbase_id
    org = crunchbase_org(5)
    self.crunchbase_id ||= org.permalink
    self.domain ||= org.url
  end

  def add_to_wit
    Http::Wit::Entity.new('company').add_value name
  end

  def yes_votes
    votes.yes.count
  end

  def no_votes
    votes.no.count
  end

  def crunchbase_org(timeout = 0.3)
    @crunchbase_org ||= Http::Crunchbase::Organization.new(self, timeout)
  end

  def trello_card
    @trello_card ||= Trello::Card.find trello_id
  end
end
