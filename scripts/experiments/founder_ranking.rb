require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative '../plots/plot_helpers'

include PlotHelpers

active_founders = Founder.where.not(history_id: nil).where.not(logged_in_at: nil).where.not("email LIKE '%dormroomfund.com'")
active_founders.count # 625 -> number of founders who gave us their graph

# Survey Mailer

def mail_survey!
  Founder.where.not(logged_in_at: nil).where.not(email: nil).find_each do |founder|
    query = { link: founder.history_id != nil, email: founder.email }
    BulkMailer.nps_survey_email(founder, 'oDrLgx', "VCWiz Feedback - I'll buy you dinner!", query).deliver_later
  end
end

# Graph Backfill

def add_edges!(scope)
  scope.in_batches do |rel|
    Parallel.each(rel, in_threads: 32) do |i|
      ActiveRecord::Base.connection_pool.with_connection do
        ops = i.send(:bulk_graph_rels)
        next unless ops.present?
        begin
          Graph.server.batch *ops
        rescue Neography::DeadlockDetectedException => e
          puts e
          retry
        end
      end
    end
  end
end

def add_investment_edges!
  add_edges! Company.includes(investments: {investor: :competitor}, founders: :primary_company)
  add_edges! Investment.includes(company: {founders: :primary_company}, investor: :competitor)
end

def backfill_graph!
  Founder.where.not(history_id: nil).pluck(:id).each do |id|
    FounderGmailBackfillJob.set(wait: 30.minutes * rand).perform_later(id, '5y', '1y')
  end
end

# Utilities

def graph_metric(f, name)
  f.graph_node.present? ? (f.graph_node[name] || 0) : 0
end

dataset = active_founders.includes(:primary_company).find_each.map do |f|
  previous_funding = total_funding(f.companies.where.not(id: f.primary_company&.id))
  current_funding = total_funding(Company.where(id: f.primary_company&.id))

  emails = fundraising_emails f
  incoming_investors = emails.where(direction: :incoming).count('DISTINCT emails.investor_id')
  outgoing_investors = emails.where(direction: :outgoing).count('DISTINCT emails.investor_id')

  email_success = incoming_investors.to_f / outgoing_investors.to_f
  email_success = 0 if email_success.nan? || email_success.infinite?

  manually_created_targets = f.target_investors.where.not(id: f.target_investors.joins("INNER JOIN emails ON emails.founder_id = #{f.id} AND target_investors.investor_id = emails.investor_id AND target_investors.created_at > emails.created_at").group('target_investors.id').select('target_investors.id'))
  manually_created_targets_responded = emails.where(investor_id: manually_created_targets.select('target_investors.investor_id')).where(direction: :incoming).count('DISTINCT emails.investor_id')
  manual_target_success = manually_created_targets_responded.to_f / manually_created_targets.count.to_f

  incoming_sentiment = Email.connection.select_value(emails.where(direction: :incoming).select('AVG(sentiment_score * sentiment_magnitude)').to_sql) || 0

  first_target_on, last_target_change = fundraising_range(f)
  fundraising_time = -TimeDifference.between(first_target_on, last_target_change).in_days

  {
    id: f.id,
    pagerank: graph_metric(f, :pagerank),
    betweenness: graph_metric(f, :betweenness),
    harmonic: graph_metric(f, :harmonic),
    previous_funding: previous_funding,
    current_funding: current_funding,
    total_funding: previous_funding + current_funding,
    incoming_investors: incoming_investors,
    email_success: email_success,
    manual_target_responds: manually_created_targets_responded,
    manual_target_success: manual_target_success,
    incoming_sentiment: incoming_sentiment,
    fundraising_time: fundraising_time,
    affiliated_exits: f.affiliated_exits || 0,
  }
end

puts dataset.to_json

def top_by_metric(dataset, metric)
  dataset.sort_by { |x| (x[metric].nil? || x[metric].to_f.nan? || x[metric].to_f.infinite?) ? 0 : x[metric] }.reverse.first(5)
end

def sort_indexes_by_metric(dataset, metric)
  order = dataset.map { |x| x[metric] }.uniq.sort.each_with_index.each_with_object({}) { |(x, i), h| h[x] = i }
  dataset.map { |x| order[x[metric]] }
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

def save_private_data(data, name)
  open("ml/experiments/founder_rank/data/private/#{name}.py", 'w') do |f|
    f.write('data = ')
    f.write(data.to_json)
  end
end

WEIGHTS = {
  total_funding: 4,
  incoming_investors: 3,
  manual_target_responds: 2,
}

baseline_scores = WEIGHTS.map do |metric, weight|
  sort_indexes_by_metric(dataset, metric).map { |x| x * weight }
end.transpose.map(&:sum)

baseline_data, baseline_sorted = data_and_sorted(dataset, baseline_scores)
relevance = baseline_data.each_with_object({}) { |x, h| h[x.first] = x.last }
puts baseline_sorted.first(5)

save_private_data baseline_data, :baseline

# Random

random_scores = active_founders.size.times.map { rand }
random_data, random_sorted = data_and_sorted(dataset, random_scores, relevance: relevance)
puts random_sorted.first(5)

save_private_data random_data, :random

# Naive Founder Rank:

active_founder_graph_metrics = active_founders.find_each.map do |founder|
  %w(pagerank betweenness harmonic).map { |prop| founder.graph_node[prop] || 0.0 }
end

naive_fr_scores = active_founder_graph_metrics.map do |metrics|
  metrics.sum / 3.0
end

naive_fr_data, naive_fr_sorted = data_and_sorted(dataset, naive_fr_scores, relevance: relevance)
puts naive_fr_sorted.first(5)

save_private_data naive_fr_data, :naive

# Weighted Founder Rank

weighted_fr_X =  dataset.map.with_index do |x, i|
  [x[:id]] + active_founder_graph_metrics[i]
end

save_private_data weighted_fr_X, :graph_metrics

exit

# Founder Rank + Investment Baseline

def founder_sql_with_funding(start, end_)
  <<-SQL
    SELECT
      founders.id,
      founders.affiliated_exits,
      founders.first_name,
      founders.last_name,
      founders.email,
      MAX(primary_company.domain) AS primary_domain,
      SUM(companies.capital_raised) AS funding_from_companies,
      COALESCE(SUM(round_sizes.round_size), 0) AS funding_from_rounds
    FROM founders
    INNER JOIN companies_founders ON companies_founders.founder_id = founders.id
    INNER JOIN companies ON companies.id = companies_founders.company_id
    INNER JOIN primary_company_joins ON primary_company_joins.founder_id = founders.id
    LEFT JOIN LATERAL (
      SELECT primary_companies.domain
      FROM companies AS primary_companies
      WHERE primary_companies.id = primary_company_joins.company_id
    ) AS primary_company ON true
    LEFT JOIN LATERAL (
      SELECT COALESCE(MAX(investments.round_size), 0) AS round_size
      FROM investments
      WHERE investments.company_id = companies_founders.company_id
      GROUP BY investments.funding_type, investments.series
    ) AS round_sizes ON true
    WHERE founders.id >= #{start} AND founders.id < #{end_}
    GROUP BY founders.id
  SQL
end

def in_batches(klass, batch_size: 5000)
  total = klass.count
  start, end_ = 0, batch_size
  results = []
  while end_ <= total
    Parallel.each(klass.find_by_sql(founder_sql_with_funding(start, end_)), in_threads: 64) do |f|
      ActiveRecord::Base.connection_pool.with_connection do
        results << (yield f)
      end
    end
    start, end_ = end_, end_ + batch_size
  end
  results
end

def save_public_data(data, name)
  open("ml/experiments/founder_rank/data/investment/#{name}.py", 'w') do |f|
    f.write('data = ')
    f.write(data.to_json)
  end
end

all_founders_dataset = in_batches(Founder) do |f|
  {
    id: f.id,
    pagerank: graph_metric(f, :pagerank),
    betweenness: graph_metric(f, :betweenness),
    harmonic: graph_metric(f, :harmonic),
    total_funding: [f.funding_from_companies, f.funding_from_rounds].max,
    affiliated_exits: f.affiliated_exits || 0,
  }
end

ALL_FOUNDERS_WEIGHTS = {
  total_funding: 1,
  affiliated_exits: 4,
}

all_founders_baseline_scores = ALL_FOUNDERS_WEIGHTS.map do |metric, weight|
  sort_indexes_by_metric(all_founders_dataset, metric).map { |x| x * weight }
end.transpose.map(&:sum)

af_baseline_data, af_baseline_sorted = data_and_sorted(all_founders_dataset, all_founders_baseline_scores)
af_relevance = af_baseline_data.each_with_object({}) { |x, h| h[x.first] = x.last }
puts af_baseline_sorted.first(5)

save_public_data af_baseline_data, :baseline

# Founder Rank + Investment Random

random_scores = all_founders_dataset.size.times.map { rand }
random_data, random_sorted = data_and_sorted(all_founders_dataset, random_scores, relevance: af_relevance)
puts random_sorted.first(5)

save_public_data random_data, :random

# Naive Founder Rank + Investment:

naive_af_scores = all_founders_dataset.map do |f|
  f.slice(:pagerank, :betweenness, :harmonic).values.sum / 3.0
end

naive_af_data, naive_af_sorted = data_and_sorted(all_founders_dataset, naive_af_scores, relevance: af_relevance)
puts naive_af_sorted.first(5)

save_public_data naive_af_data, :naive

# Weighted Founder Rank + Investment

weighted_af_X =  all_founders_dataset.map do |x|
  [x[:id], x[:pagerank], x[:betweenness], x[:harmonic]]
end

save_public_data weighted_af_X, :graph_metrics

# Weighted Founder Rank + Investment + Email
