require_relative '../config/boot'
require_relative '../config/environment'

active_founders = Founder.where.not(history_id: nil).where.not(logged_in_at: nil).where.not("email LIKE '%dormroomfund.com'")
active_founders.count # 552 -> number of founders who gave us their graph

# Survey Mailer

def mail_survey!
  Founder.where.not(logged_in_at: nil).where.not(email: nil).find_each do |founder|
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

dataset = active_founders.find_each.map do |f|
  previous_funding = total_funding(f.companies.where.not(id: f.primary_company&.id))
  current_funding = total_funding(Company.where(id: f.primary_company&.id))

  emails = f.emails.where.not(investor: nil).where(bulk: false)
  incoming_investors = emails.where(direction: :incoming).count('DISTINCT emails.investor_id')
  outgoing_investors = emails.where(direction: :outgoing).count('DISTINCT emails.investor_id')

  email_success = incoming_investors.to_f / outgoing_investors.to_f
  email_success = 0 if email_success.nan? || email_success.infinite?

  manually_created_targets = f.target_investors.where.not(id: f.target_investors.joins("INNER JOIN emails ON emails.founder_id = #{f.id} AND target_investors.investor_id = emails.investor_id AND target_investors.created_at > emails.created_at").group('target_investors.id').select('target_investors.id'))
  manually_created_targets_responded = emails.where(investor_id: manually_created_targets.select('target_investors.investor_id')).where(direction: :incoming).count('DISTINCT emails.investor_id')
  manual_target_success = manually_created_targets_responded.to_f / manually_created_targets.count.to_f

  incoming_sentiment = Email.connection.select_value(emails.where(direction: :incoming).select('AVG(sentiment_score * sentiment_magnitude)').to_sql) || 0

  {
    id: f.id,
    pagerank: f.graph_node[:pagerank],
    betweenness: f.graph_node[:betweenness],
    harmonic: f.graph_node[:harmonic],
    previous_funding: previous_funding,
    current_funding: current_funding,
    total_funding: previous_funding + current_funding,
    incoming_investors: incoming_investors,
    email_success: email_success,
    manual_target_responds: manually_created_targets_responded,
    manual_target_success: manual_target_success,
    incoming_sentiment: incoming_sentiment,
  }
end

puts dataset.to_json

def top_by_metric(dataset, metric)
  dataset.sort_by { |x| (x[metric].nil? || x[metric].to_f.nan? || x[metric].to_f.infinite?) ? 0 : x[metric] }.reverse.first(5)
end

def sort_indexes_by_metric(dataset, metric)
  order = dataset.map { |x| x[metric] }.uniq.sort
  dataset.map { |x| order.index(x[metric]) }
end

puts top_by_metric(dataset, :previous_funding) # best
puts top_by_metric(dataset, :current_funding) # best
puts top_by_metric(dataset, :incoming_sentiment) # surprisingly good, lots of DRF and YC companies. SHOW how high sentiment correlates with number of well-respected investors.
puts top_by_metric(dataset, :incoming_investors) # good, shows lots of inbound interest
puts top_by_metric(dataset, :email_success) # not as good, because some people just never send (maybe the cofounder is doing it)
puts top_by_metric(dataset, :manual_target_success) # not as good, absolute number would be better
puts top_by_metric(dataset, :manual_target_responds) # high-signal for companies in their early days of raising, indicates consistent success capturing attention

# Baseline: weighted combo of ranking in each of these schemes

WEIGHTS = {
  total_funding: 4,
  incoming_investors: 3,
  manual_target_responds: 2,
  incoming_sentiment: 1.5,
}

indexes = WEIGHTS.map do |metric, weight|
  sort_indexes_by_metric(dataset, metric).map { |x| x * weight }
end.transpose.map(&:sum)

sorted = dataset.map.with_index.sort_by { |x,i| indexes[i] }.reverse.map(&:first)

# Naive Founder Rank:

naive_fr = active_founders.find_each.map do |founder|
  %w(pagerank betweenness harmonic).map { |prop| founder.graph_node[prop] || 0.0 }.sum / 3.0
end

sorted_by_nrf = dataset.zip(naive_fr).sort_by(&:last).reverse.map(&:first)

# fix 0-1 scaling

