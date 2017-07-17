require 'csv'
require 'open-uri'

module Importers::Internal
  class VotingBase < Importers::Base
    def import!(parsed)
      return unless parsed[:date].present? && parsed[:email].present? && parsed[:company].present?

      date = parsed[:date].is_a?(String) ? Chronic.parse(parsed[:date]) : parsed[:date]
      return unless date.present?

      date_minus_epsilon = date - 1.minute
      date_plus_epsilon = date + 1.minute

      company_name = Rails.application.config.overrides['import']['company']['name'][parsed[:company]] || parsed[:company]
      companies = Company.search(company_name)
      company = Company.where(name: company_name).first || companies.first if companies.count == 1
      unless company.present?
        Rails.logger.warn "Skipping record #{parsed}"
        return
      end
      company.team = team
      company.decision_at = [company.decision_at, date].compact.max
      company.pitch_on = [company.pitch_on, date.to_date].compact.min
      company.override_quorum = true
      company.save! if company.changed?

      username = parsed[:email].split('@').first
      user = User.where(username: username).first_or_create! do |user|
        user.created_at = date_minus_epsilon
        user.inactive_since = date_plus_epsilon
      end

      user.team = team
      user.created_at = [user.created_at, date_minus_epsilon].min
      user.inactive_since = [user.inactive_since, date_plus_epsilon].max if user.inactive_since.present?
      user.save! if user.changed?

      vote_data = parsed.slice(:product, :market, :team, :fit, :overall, :reason)
      vote_data.each do |k, v|
        next if k == :reason
        vote_data[k] = v.to_i
        vote_data[k] = nil if vote_data[k] == 0
      end
      vote_data[:fit] = 3 unless vote_data[:fit].present? # Handle legacy votes where fit was not a category
      vote_data[:overall] = 2 if vote_data[:overall] == 3 # Handle legacy votes where an overall of 3 was valid as a pass
      vote_data[:final] = vote_data[:overall].present?
      vote_data[:reason] = 'No reason given!' if vote_data[:final] && vote_data[:reason].blank?
      vote_data[:user] = user
      vote_data[:company] = company
      begin
        vote = Vote.new vote_data
        vote.skip_eligibility!
        vote.save!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.warn "Skipping record due to invalid vote (#{e.message}): #{vote_data}"
        return
      end
    end

    private

    def extract_email(name, emails = {})
      emails[name] || team.users.where('cached_name ILIKE ?', "#{name}%").first&.username
    end
  end
end
