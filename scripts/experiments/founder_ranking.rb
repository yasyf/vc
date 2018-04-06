require_relative '../config/boot'
require_relative '../config/environment'

active_founders = Founder.where.not(history_id: nil).where.not(logged_in_at: nil).where.not("email LIKE '%dormroomfund.com'")
active_founders.count # 558 -> number of founders who gave us their graph

# Survey Mailer

def mail_survey!
  Founder.where.not(logged_in_at: nil).where.not(email: nil).find_each do |founder|
    query = { link: founder.history_id != nil, email: founder.email }
    BulkMailer.nps_survey_email(founder, 'oDrLgx', "VCWiz Feedback - I'll buy you dinner!", query).deliver_later
  end
end

# Graph Backfill

def backfill_graph!
  Founder.where.not(history_id: nil).pluck(:id).each do |id|
    FounderGmailBackfillJob.set(wait: 30.minutes * rand).perform_later(id, '5y', '1y')
  end
end

# Utilities

def total_funding(companies)
  funding_from_companies = companies.sum('companies.capital_raised')

  sql = Investment.where(company: companies).group('investments.funding_type, investments.series').select('MAX(investments.round_size)').to_sql
  funding_from_rounds = Investment.connection.select_values(sql).compact.sum

  [funding_from_companies, funding_from_rounds].max
end

dataset = active_founders.includes(:primary_company).find_each.map do |f|
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
puts top_by_metric(dataset, :manual_target_success) # not as good, absolute number would be better, since they might have only targetted a few who they know will want to fund them
puts top_by_metric(dataset, :manual_target_responds) # high-signal for companies in their early days of raising, indicates consistent success capturing attention

# Baseline: weighted combo of ranking in each of these schemes

def normalize(x, min, max)
  (x - min).to_f / (max - min).to_f
end

def data_and_sorted(dataset, scores, relevance: nil)
  min_score, max_score = [scores.min, scores.max]

  data_raw = dataset.zip(scores).sort_by(&:last)
  data = data_raw
    .map.with_index
    .map { |(x, score), rank| [x[:id], normalize(score, min_score, max_score), relevance.present? ? relevance[x[:id]] : rank + 1] } # [[id, score, relevance]]
    .reverse

  sorted = data_raw.map(&:first).reverse

  [data, sorted]
end

WEIGHTS = {
  total_funding: 4,
  incoming_investors: 3,
  manual_target_responds: 2,
  incoming_sentiment: 1,
}

baseline_scores = WEIGHTS.map do |metric, weight|
  sort_indexes_by_metric(dataset, metric).map { |x| x * weight }
end.transpose.map(&:sum)

baseline_data, baseline_sorted = data_and_sorted(dataset, baseline_scores)
relevance = baseline_data.each_with_object({}) { |x, h| h[x.first] = x.last }
puts baseline_sorted.first(5)

# Random

random_scores = active_founders.size.times.map { rand }
random_data, random_sorted = data_and_sorted(dataset, random_scores, relevance: relevance)
puts random_sorted.first(5)

# Naive Founder Rank:

active_founder_graph_metrics = active_founders.find_each.map do |founder|
  %w(pagerank betweenness harmonic).map { |prop| founder.graph_node[prop] || 0.0 }
end

naive_fr_scores = active_founder_graph_metrics.map do |metrics|
  metrics.sum / 3.0
end

naive_fr_data, naive_fr_sorted = data_and_sorted(dataset, naive_fr_scores, relevance: relevance)
puts naive_fr_sorted.first(5)

# Weighted Founder Rank

weighted_fr_X =  dataset.map.with_index do |x, i|
  [x[:id]] + active_founder_graph_metrics[i]
end

# Founder Rank + Investment

# Weighted Founder Rank + Investment
