class CompanySyncJob < ApplicationJob
  queue_as :default

  IGNORED_COMPANY_PREFIX = 'jobs/company_sync/ignored/trello_id'

  def perform(team, quiet: true, importing: false, deep: false)
    Importers::Internal::Trello.new(team).sync!(deep: deep) do |card_data|
      if ignored? card_data[:trello_id]
        next
      end

      if card_data.delete(:closed)
        Card.where(trello_id: card_data[:trello_id]).update_all(archived: true)
        next
      end

      card_data[:pitch_on] = team.time_now if importing && card_data[:pitch_on].blank?

      Rails.logger.info "[Company Sync] Processing #{card_data[:name]} (#{card_data[:trello_list_id]})"

      users = users_from_card_data team, card_data
      list = List.where(trello_id: card_data.delete(:trello_list_id)).first!

      card = Card.where(trello_id: card_data[:trello_id]).first_or_initialize
      card.company ||= Company.where(name: card_data[:name]).first_or_initialize

      company = card.company
      pitch = company.pitch

      if (pitch.blank? || pitch.decided?) && card_data[:pitch_on].present?
        pitch = Pitch.create!(company: company, when: card_data[:pitch_on])
      end

      if pitch.present?
        pitch.when = card_data[:pitch_on] if card_data[:pitch_on].present?
        pitch.decision ||= team.time_now if importing
        pitch.save! if pitch.changed?
      end

      if card.list.present? && card.list != list
        LoggedEvent.log! :card_list_changed, card,
          notify: 0, data: { from: card.list.trello_id, to: list.trello_id, date: Date.today }
      end

      company.team = team
      card.list = list
      company.users = users

      try_save! company

      company.send(:add_to_wit!) unless company.name == company.name_was

      next unless deep

      company.set_extra_attributes!
      next unless company.changed? && company.valid?

      log_events! company unless quiet

      try_save! company

      pitch.decide!(override: false) if pitch.present? && pitch.undecided? && company.passed?
    end
  end

  private

  def ignored?(trello_id)
    Rails.cache.exist?("#{IGNORED_COMPANY_PREFIX}/#{trello_id}")
  end

  def ignore!(trello_id)
    Rails.cache.write("#{IGNORED_COMPANY_PREFIX}/#{trello_id}", true, expires_in: 1.month)
  end

  def try_save!(company)
    company.card.save! if company.card.changed?
    company.pitch.save! if company.pitch&.changed?
    if company.changed?
      begin
        company.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
        Rails.logger.error "[Company Sync] Invalid Company Data (#{e.message})\n#{company.serializable_hash}"
        ignore! company.card.trello_id if company.card.trello_id.present?
      end
    end
  end

  def log_events!(company)
    if company.capital_raised > 20_000 && company.capital_raised != company.capital_raised_was
      message = "#{company.cb_slack_link} has now raised at least #{company.capital_raised(format: true)}!"
      company.add_comment! message, notify: true
    end
    company.competitors.each do |competitor|
      LoggedEvent.do_once(company, "notify_competitor_#{competitor.acronym.downcase}") do
        company.add_comment! "#{competitor.name} has now funded #{company.cb_slack_link}!", notify: true
      end
    end
  end

  def users_from_card_data(team, card_data)
    card_data.delete(:members).map do |member|
      User.from_trello(member.id).tap do |user|
        if user.present?
          user.team = team
          user.trello_id = member.id
          user.save! if user.changed?
        end
      end
    end.compact
  end
end
