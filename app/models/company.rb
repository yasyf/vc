class Company < ActiveRecord::Base
  include Concerns::Cacheable
  include ActionView::Helpers::NumberHelper

  DEFAULT_DEADLINE = (2.5).days

  has_many :votes
  belongs_to :list
  belongs_to :team
  has_and_belongs_to_many :users
  has_and_belongs_to_many :competitors

  validates :name, presence: true
  validates :team, presence: true
  validates :list, presence: true
  validates :trello_id, presence: true, uniqueness: true
  validates :domain, uniqueness: { allow_nil: true }
  validates :crunchbase_id, uniqueness: { allow_nil: true }
  validates :cached_funded, inclusion: [true, false]
  validates :capital_raised, presence: true, numericality: { only_integer: true }

  scope :pitch, -> { where('pitch_on IS NOT NULL') }
  scope :decided, -> { where.not(decision_at: nil) }
  scope :undecided, -> { where(decision_at: nil) }
  scope :search, Proc.new { |term| where('name ILIKE ?', "%#{term}%") if term.present? }
  scope :portfolio, -> { where(cached_funded: true) }

  before_create :set_extra_attributes!
  after_create :add_to_wit!

  def domain=(domain)
    super begin
      URI.parse(domain).host
    rescue URI::InvalidURIError
      domain
    end
  end

  def pitch_on
    super&.in_time_zone('UTC')&.in_time_zone(team.time_zone)
  end

  def deadline
    super || pitch_on + DEFAULT_DEADLINE if pitch_on.present?
  end

  def pitched?
    pitch_on.present? && pitch_on < team.time_now
  end

  def past_deadline?
    pitched? && (decision_at.present? || deadline < team.time_now)
  end

  def passed?
    list.in?([team.lists.rejected, team.lists.passed])
  end

  def quorum?
    cached(cache_unless_voting) do
      override_quorum? || pitch_on.present? && votes.valid(team, pitch_on).count >= User.quorum(team, pitch_on)
    end
  end

  def funded?
    cached_funded || list.in?(team.funded_lists) || (quorum? && yes_votes > no_votes)
  end

  def vote_for_user(user)
    user_votes(user).final.first
  end

  def stats
    cached(cache_unless_voting) do
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
    return unless list == team.lists.scheduled
    return unless pitch_on.present?
    return unless snapshot_link.present? || (pitch_on.to_datetime - team.datetime_now) < DEFAULT_DEADLINE
    LoggedEvent.do_once(self, :prepare_team) do
      VoteMailer.email_and_slack!(:upcoming_pitch_email, team, self, cc_all: true)
    end
  end

  def warn_team!(missing_users, time_remaining)
    LoggedEvent.do_once(self, :warn_team) do
      VoteMailer.email_and_slack!(:vote_warning_team_email, team, missing_users, self, time_remaining.to_i)
    end
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
    list = funded? ? team.lists.pre_funded : team.lists.passed
    move_to_list! list

    trello_card.name = name
    trello_card.save
  end

  def self.sync!(quiet: true, importing: false, deep: false)
    Team.for_each do |team|
      CompanySyncJob.perform_later(team, quiet: quiet, importing: importing, deep: deep)
    end
  end

  def user_votes(user)
    votes.where(user: user).order(created_at: :desc)
  end

  def missing_vote_users
    votes.where(final: false).map(&:user) - votes.final.map(&:user)
  end

  def missing_votes
    votes.where(final: false).where(user: missing_vote_users)
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

    users << user
    save!
  rescue Trello::Error
  end

  def add_comment!(comment, notify: false)
    team.notify!(comment, all: false) if notify
    trello_card.add_comment "**[DRFBot]** #{comment}"
  end

  def as_json(options = {})
    options.reverse_merge!(
      methods: [:trello_url, :stats, :competitors],
      only: [
        :id,
        :name,
        :trello_id,
        :snapshot_link,
        :domain,
        :description,
      ]
    )
    key_cached(
      options.slice(:methods, :only, :except, :root, :include),
      cache_unless_voting(expires_in: jitter(1, :day)),
    ) do
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
  end

  def set_extra_attributes!
    set_snapshot_link!
    set_crunchbase_attributes!
    set_competitors!
    set_capital_raised!
  end

  def invalidate_crunchbase_id!
    self.crunchbase_id = "#{Http::Crunchbase::Organization::INVALID_KEY}_#{param_name}"
    self.domain = nil
    self.description = nil
    self.capital_raised = funded? ? 20_000 : 0
    save!
  end

  def param_name
    name.gsub(' ', '').parameterize
  end

  def prevote_comments_doc
    if prevote_doc_link.blank?
      # Acquiring the lock reloads the model, so only one thread will actually create a new doc.
      # The others will see the link after they acquire the lock, and will leave the record untouched.
      with_lock do
        self.prevote_doc_link ||= find_or_create_prevote_doc!
        save!
      end
    end
    prevote_doc_link
  end

  def team
    return nil unless (cached_team = super).present?
    Team.send(cached_team.name)
  end

  def crunchbase_org(timeout = 1)
    @crunchbase_org ||= Http::Crunchbase::Organization.new(self, timeout)
  end

  def cb_slack_link
    "<#{crunchbase_org.crunchbase_url}|#{name}>"
  end

  def tweeter
    Tweeter.where(username: twitter_username).first_or_create! if twitter_username.present?
  end

  private

  def twitter_username
    cached { crunchbase_org.twitter }
  end

  def find_or_create_prevote_doc!
    file_name = "[#{id}] #{name} Prevote Discussion"
    drive = GoogleApi::Drive.new
    begin
      drive.find(file_name, in_folders: team.prevote_discussions_folder_id, cache: false) || drive.create(
        file_name,
        'application/vnd.google-apps.document',
        StringIO.new(User.active(team).shuffle.map { |user| "<div><h2>#{user.name}</h2></div>" }.join("\n")),
        team.prevote_discussions_folder_id,
        'text/html',
      )
    end.web_view_link
  end

  def cache_unless_voting(options = {})
    options[:force] = true if pitch_on.present? && decision_at.blank?
    options
  end

  def set_snapshot_link!
    self.snapshot_link = begin
      if team.snapshot_folder_ids.present?
        GoogleApi::Drive.new.find(name.gsub(/['"]/, ''), in_folders: team.snapshot_folder_ids)
      end || GoogleApi::Drive.new.find("#{name.gsub(/['"]/, '')} Snapshot", excludes: team.exclude_folder_ids)
    end&.web_view_link
  end

  def set_crunchbase_attributes!
    org = crunchbase_org(5)
    return unless org.permalink
    self.crunchbase_id = org.permalink
    self.domain = org.url
    self.description = org.description
  end

  def set_competitors!
    self.competitors = Competitor.for_company(self)
  end

  def set_capital_raised!
    self.capital_raised = [crunchbase_org(5).total_funding.to_i || 0, funded? ? 20_000 : 0].max
  end

  def add_to_wit!
    Http::Wit::Entity.new('company').add_value name
  end

  def yes_votes
    votes.yes.count
  end

  def no_votes
    votes.no.count
  end

  def trello_card
    @trello_card ||= Trello::Card.find trello_id
  end
end
