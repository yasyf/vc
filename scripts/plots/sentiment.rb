require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative './plot_helpers'

include ActionView::Helpers::DateHelper
include PlotHelpers

FEATURED_COMPETITORS = [2, 3, 5, 24784, 280, 120, 350, 319]

dataset = fundraised_founders.find_each.map do |founder|
  first_target_on, last_target_change = fundraising_range founder
  difference = TimeDifference.between(first_target_on, last_target_change)

  emails = fundraising_emails(founder)
    .where('emails.created_at >= ?', first_target_on)
    .where('emails.created_at <= ?', last_target_change)
    .where(direction: :incoming)

  avg_sentiment = Email.connection.select_value(emails.select('AVG(sentiment_score * sentiment_magnitude)').to_sql) || 0
  funding = total_funding founder.companies
  interested_featured_investors = emails.joins(:investor).where('investors.featured': true).count('DISTINCT investors.id')
  interested_featured_competitors = emails.joins(:investor).where('investors.competitor_id': FEATURED_COMPETITORS).count('DISTINCT investors.competitor_id')

  [avg_sentiment, funding, interested_featured_investors, interested_featured_competitors, difference.in_weeks]
end

puts dataset.first(5).to_s
save_data dataset, :sentiment
