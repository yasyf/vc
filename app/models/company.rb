class Company < ActiveRecord::Base
  include Concerns::Cacheable
  include ActionView::Helpers::NumberHelper

  has_many :votes
  belongs_to :list
  belongs_to :team
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :team, presence: true
  validates :list, presence: true
  validates :trello_id, presence: true, uniqueness: true
  validates :domain, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :rdv_funded, inclusion: [true, false]
  validates :capital_raised, presence: true, numericality: { only_integer: true }

  scope :pitch, -> { where('pitch_on IS NOT NULL') }
  scope :decided, -> { where.not(decision_at: nil) }
  scope :undecided, -> { where(decision_at: nil) }
  scope :search, Proc.new { |term| where('name ILIKE ?', "%#{term}%") if term.present? }

  before_create :set_extra_attributes!
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

  def passed?
    list.in?([team.lists.rejected, team.lists.passed])
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

  def partner_names
    cached { users.map(&:name) }
  end

  def notify_team!
    VoteMailer.email_and_slack!(:funding_decision_email, team, self, cc_all: true)
  end

  def prepare_team!
    VoteMailer.email_and_slack!(:upcoming_pitch_email, team, self, cc_all: true)
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

  def self.sync!(quiet: true, importing: false)
    Team.for_each do |team|
      Importers::Trello.new(team).sync! do |card_data|
        Rails.logger.info "[Company Sync] Processing #{card_data[:name]} (#{card_data[:trello_list_id]})"

        users = card_data.delete(:members).map do |member|
          User.from_trello(member.id).tap do |user|
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
        company.decision_at ||= Time.now if importing && company.pitch_on == nil
        if company.list.present? && company.list != list
          LoggedEvent.log! :company_list_changed, company,
            notify: 0, data: { from: company.list.trello_id, to: list.trello_id, date: Date.today }
          if list == team.lists.scheduled
            company.prepare_team!
          end
        end
        company.team = team
        company.list = list
        company.users = users

        if company.changed?
          begin
            company.save!
          rescue ActiveRecord::RecordInvalid => e
            LoggedEvent.log! :invalid_company_data, list, company.serializable_hash, e.message, company.trello_url,
              list.name, to: users, notify: 0, data: { company: company.serializable_hash, message: e.message }
          end
        end

        company.set_extra_attributes!
        next unless company.changed? && company.valid?
        if !quiet
          if company.capital_raised > 20_000 && company.capital_raised != company.capital_raised_was
            message = "*#{company.name}* has now raised at least #{company.capital_raised(format: true)}!"
            company.add_comment message, notify: true
          end
          if company.rdv_funded? && !company.rdv_funded_was
            company.add_comment "RDV has now funded *#{company.name}*!", notify: true
          end
        end
        company.save!

      end
    end
  end

  def user_votes(user)
    votes.where(user: user).order(created_at: :desc)
  end

  def trello_url
    "https://trello.com/c/#{trello_id}"
  end

  def capital_raised(format: false)
    format ? number_to_human(super(), locale: :money) : super()
  end

  def add_user(user)
    trello_card.add_member user.trello_user
    trello_card.save
  end

  def add_comment(comment, notify: false)
    team.notify!(comment, all: false) if notify
    trello_card.add_comment "**[DRFBot]** #{comment}"
  end

  def as_json(options = {})
    options.reverse_merge!(
      methods: [:trello_url, :stats],
      only: [:id, :name, :trello_id, :snapshot_link, :domain, :rdv_funded, :description]
    )
    super(options).merge(
      capital_raised: capital_raised(format: true),
      pitch_on: pitch_on&.to_time&.to_i,
      funded: funded?,
      passed: passed?,
      past_deadline: past_deadline?,
      pitched: pitched?,
      partners: users.map { |user| { name: user.name, slack_id: user.slack_id }  }
    )
  end

  def set_extra_attributes!
    set_snapshot_link!
    set_crunchbase_attributes!
    set_rdv_funded!
    set_capital_raised!
  end

  private

  def set_snapshot_link!
    self.snapshot_link = GoogleApi::Drive.new.find("#{name.gsub(/['"]/, '')} Snapshot")&.web_view_link
  end

  def set_crunchbase_attributes!
    org = crunchbase_org(5)
    self.crunchbase_id = org.permalink
    self.domain = org.url
    self.description = org.description
  end

  def set_rdv_funded!
    self.rdv_funded = crunchbase_org(5).has_investor?('Rough Draft Ventures') || Http::Rdv.new.invested?(name)
  end

  def set_capital_raised!
    self.capital_raised = [crunchbase_org(5).total_funding.to_i || 0, funded? ? 20_000 : 0].max
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

  def crunchbase_org(timeout = 1)
    @crunchbase_org ||= Http::Crunchbase::Organization.new(self, timeout)
  end

  def trello_card
    @trello_card ||= Trello::Card.find trello_id
  end
end
