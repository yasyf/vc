class CompanySyncJob < ApplicationJob
  queue_as :default

  def perform(team, quiet: true, importing: false, deep: false)
    Importers::Trello.new(team).sync!(deep: deep) do |card_data|
      if card_data.delete(:closed)
        Company.where(trello_id: card_data[:trello_id]).destroy_all
        next
      end

      Rails.logger.info "[Company Sync] Processing #{card_data[:name]} (#{card_data[:trello_list_id]})"

      users = users_from_card_data team, card_data
      list = List.where(trello_id: card_data.delete(:trello_list_id)).first!

      company = Company.where(trello_id: card_data[:trello_id]).first_or_initialize
      company.assign_attributes card_data
      company.decision_at ||= team.time_now if importing && company.pitch_on == nil

      if company.list.present? && company.list != list
        LoggedEvent.log! :company_list_changed, company,
          notify: 0, data: { from: company.list.trello_id, to: list.trello_id, date: Date.today }
      end

      company.team = team
      company.list = list
      company.users = users

      company.cached_funded = true if company.funded?
      company.cached_funded = false if company.passed?

      try_save! company

      company.send(:add_to_wit!) unless company.name == company.name_was

      next unless deep

      company.set_extra_attributes!
      next unless company.changed? && company.valid?

      log_events! company unless quiet

      try_save! company

      company.decide!(override: false) if company.undecided? && company.passed?
    end
  end

  private

  def try_save!(company)
    if company.changed?
      begin
        company.save!
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
        Rails.logger.error "[Company Sync] Invalid Company Data (#{e.message})\n#{company.serializable_hash}"
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
