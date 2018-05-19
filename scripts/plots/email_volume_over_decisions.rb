require_relative '../../config/boot'
require_relative '../../config/environment'

include ActionView::Helpers::DateHelper

founders = Founder.where.not(logged_in_at: nil)
eligible = founders.joins(:target_investors).where('target_investors.stage > 3').group('founders.id')

raised_for = eligible.find_each.map do |founder|
  first_target_on = founder.target_investors.order(created_at: :asc).first.created_at
  last_target_change = founder.target_investors.order(updated_at: :desc).first.updated_at

  months = TimeDifference.between(first_target_on, last_target_change).in_months
  months == 0 ? nil : months
end.compact

puts raised_for.sum / raised_for.size
