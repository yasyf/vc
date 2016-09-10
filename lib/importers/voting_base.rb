require 'csv'
require 'open-uri'

module Importers
  class VotingBase
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
      vote_data[:final] = vote_data[:overall].present?
      vote_data[:reason] = 'No reason given!' if vote_data[:final] && vote_data[:reason].blank?
      vote_data[:user] = user
      vote_data[:company] = company
      begin
        vote = Vote.new vote_data
        vote.skip_eligibility!
        vote.save!
      rescue ActiveRecord::RecordInvalid
        return
      end
    end

    private

    def url?(filename)
      filename =~ /\A#{URI::regexp(%w(ftp http https))}\z/
    end

    def save(input)
      file = Tempfile.new 'csv'
      stream = input.is_a?(StringIO) ? input.tap(&:rewind) : open(input)
      IO.copy_stream stream, file.path
      file.path
    end
  end
end
