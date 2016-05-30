require 'csv'

module Importers
  class Csv
    HEADERS = {
      date: 'Date',
      email: 'Username',
      product: 'Product',
      market: 'Market',
      team: 'Team',
      fit: 'Fit',
      overall: 'Overall',
      reason: 'Reason For Voting',
      company: 'Company'
    }

    def initialize(filename)
      @filename = filename
    end

    def sync!
      ::CSV.foreach(@filename, headers: true) do |row|
        parsed = HEADERS.map { |h,s| [h, row[s]] }.to_h
        next unless parsed[:date].present? && parsed[:email].present? && parsed[:company].present?

        date = Chronic.parse(parsed[:date])
        date_minus_epsilon = date - 1.minute
        date_plus_epsilon = date + 1.minute

        company = Company.where(name: parsed[:company]).first
        next unless company.present?
        company.decision_at = [company.decision_at, date].compact.max
        company.pitch_on = [company.pitch_on, date.to_date].compact.min
        company.save! if company.changed?

        username = parsed[:email].split('@').first
        user = User.where(username: username).first_or_create! do |user|
          user.created_at = date_minus_epsilon
          user.inactive_since = date_plus_epsilon
        end

        user.created_at = [user.created_at, date_minus_epsilon].min
        user.inactive_since = [user.inactive_since, date_plus_epsilon].max if user.inactive_since.present?
        user.save! if user.changed?

        vote_data = parsed.slice(:product, :market, :team, :fit, :overall, :reason)
        vote_data[:final] = vote_data[:overall].present?
        vote_data[:reason] = 'No reason given!' if vote_data[:final] && vote_data[:reason].blank?
        vote_data[:user] = user
        vote_data[:company] = company
        begin
          Vote.create! vote_data
        rescue ActiveRecord::RecordInvalid
          next
        end
      end
    end
  end
end
