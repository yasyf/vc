class Pitch < ApplicationRecord
  include Concerns::Cacheable

  DEFAULT_DEADLINE = (2.5).days

  belongs_to :company
  has_one :team, through: :company
  has_many :votes

  validates :company, presence: true
  validates :when, presence: true
  validates :snapshot, uniqueness: { allow_nil: true }
  validates :prevote_doc, uniqueness: { allow_nil: true }

  before_create :find_snapshot!

  def when
    super&.in_time_zone(team.time_zone)
  end

  def prevote_doc(create: false)
    if super().blank? && create
      # Acquiring the lock reloads the model, so only one thread will actually create a new doc.
      # The others will see the link after they acquire the lock, and will leave the record untouched.
      with_lock do
        self[:prevote_doc] ||= find_or_create_prevote_doc!
        save!
      end
    end
    super()
  end

  def deadline
    super || self.when + DEFAULT_DEADLINE
  end

  def undecided?
    !decided?
  end

  def decided?
    decision.present?
  end

  def pitched?
    self.when < team.time_now
  end

  def past_deadline?
    pitched? && (decision.present? || deadline < team.time_now)
  end

  def funded?
    cached(cache_unless_voting) { yes_votes > no_votes }
  end

  def yes_votes
    votes.yes.count
  end

  def no_votes
    votes.no.count
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

  def vote_for_user(user)
    user_votes(user).final.first
  end

  def stats
    cached(cache_unless_voting) do
      {
          yes_votes: yes_votes,
          no_votes: no_votes,
          required_votes: User.quorum(team, self.when),
          averages: Vote.metrics(votes.final)
      }.with_indifferent_access
    end
  end

  def prepare_team!
    return unless company.in_list?(team.lists.scheduled)
    set_snapshot! unless snapshot.present?
    return unless snapshot.present? || (self.when - team.datetime_now) < DEFAULT_DEADLINE
    LoggedEvent.do_once(self, :prepare_team) do
      VoteMailer.email_and_slack!(:upcoming_pitch_email, team, self.company, cc_all: true)
    end
  end

  def notify_team!
    VoteMailer.email_and_slack!(:funding_decision_email, team, self.company, cc_all: true)
  end

  def warn_team!(missing_users, time_remaining)
    LoggedEvent.do_once(self, :warn_team) do
      VoteMailer.email_and_slack!(:vote_warning_team_email, team, missing_users, self, time_remaining.to_i)
    end
  end

  def set_snapshot!
    find_snapshot!
    save!
  end

  def decide!(override: nil)
    update! decision_at: Time.current, funded: override || funded?
  end

  private

  def google_drive
    @google_drive ||= GoogleApi::Drive.new(company.users.first || team.users.first)
  end

  def find_or_create_prevote_doc!
    file_name = "[#{id}] #{company.name} Prevote Discussion"
    begin
      google_drive.find(file_name, in_folders: team.prevote_discussions_folder_id, cache: false) || google_drive.create(
          file_name,
          'application/vnd.google-apps.document',
          StringIO.new(User.active(team).shuffle.map { |user| "<div><h2>#{user.name}</h2></div>" }.join("\n")),
          team.prevote_discussions_folder_id,
          'text/html',
      )
    end.web_view_link
  end

  def find_snapshot!
    escaped_name = company.name.gsub(/['"]/, '')
    self.snapshot ||= begin
      if team.snapshot_folder_ids.present?
        google_drive.find(escaped_name, in_folders: team.snapshot_folder_ids)
      end || google_drive.find("#{escaped_name} Snapshot", excludes: team.exclude_folder_ids)
    end&.web_view_link
  end

  def cache_unless_voting(options = {})
    options[:force] = true if decision.blank?
    options
  end
end
