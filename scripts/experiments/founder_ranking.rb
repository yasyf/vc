require_relative '../config/boot'
require_relative '../config/environment'

active_founders = Founder.where.not(history_id: nil).where.not(logged_in_at: nil).where.not("email LIKE '%dormroomfund.com'")
active_founders.count # 549 -> number of founders who gave us their graph

# Survey Mailer

def mail_survey!
  Founder.where.not(logged_in_at: nil).find_each do |founder|
    query = { link: founder.history_id != nil, email: founder.email }
    BulkMailer.nps_survey_email(founder, 'oDrLgx', "VCWiz Feedback - I'll buy you dinner!", query).deliver_later
  end
end

# Utilities

def total_funding(companies)
  funding_from_companies = companies.sum('companies.capital_raised')

  sql = Investment.where(company: companies).group('investments.funding_type, investments.series').select('MAX(investments.round_size)').to_sql
  funding_from_rounds = Investment.connection.select_values(sql).compact.sum

  [funding_from_companies, funding_from_rounds].max
end

active_founders.find_each.map do |f|
  previous_funding = f.companies.where.not(id: f.primary_company&.id)
  current_funding = Company.where(id: f.primary_company&.id)

end
