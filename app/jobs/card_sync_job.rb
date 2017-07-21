class CardSyncJob < ApplicationJob
  include Concerns::TrelloIgnorable

  queue_as :low

  def perform(team, card_data, deep: false, quiet: true)
    card_data = card_data.with_indifferent_access

    users = users_from_card_data team, card_data
    list = List.where(trello_id: card_data.delete(:trello_list_id)).first!

    card = Card.where(trello_id: card_data[:trello_id]).first_or_initialize
    card.company ||= Company.where(name: card_data[:name]).first_or_initialize

    company = card.company
    pitch = company.pitch

    if (pitch&.card != card) && card_data[:pitch_on].present?
      pitch = Pitch.new(company: company, card: card, when: card_data[:pitch_on])
    end

    if pitch.present?
      pitch.when = card_data[:pitch_on] if card_data[:pitch_on].present?
    end

    company.team = team
    card.list = list
    company.users = users

    card.save! if card&.changed?
    pitch.save! if pitch&.changed?
    try_save! company

    if card.list.present? && card.list != list
      LoggedEvent.log! :card_list_changed, card,
                       notify: 0, data: { from: card.list.trello_id, to: list.trello_id, date: Date.today }
    end

    company.send(:add_to_wit!) unless company.name == company.name_was

    return unless deep

    company.set_extra_attributes!
    return unless company.changed? && company.valid?

    log_events! company unless quiet

    try_save! company

    pitch.decide!(override: false) if pitch.present? && pitch.undecided? && company.passed?
  end

  private


  def try_save!(company)
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
      User.from_trello(member[:id]).tap do |user|
        if user.present?
          user.team = team
          user.trello_id = member[:id]
          user.cached_name ||= member[:full_name]
          user.save! if user.changed?
        end
      end
    end.compact
  end
end
