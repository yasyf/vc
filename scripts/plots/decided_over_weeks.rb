require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative './plot_helpers'

include ActionView::Helpers::DateHelper
include PlotHelpers

dataset = parallel_map(fundraised_founders) do |founder|
  first_target_on, last_target_change = fundraising_range founder

  difference = TimeDifference.between(first_target_on, last_target_change)
  next if difference.in_months < 1

  events = founder
    .target_investors.joins(:events)
    .where('events.action': :state_changed)
    .where('events.arg1': TargetInvestor::STAGES.keys.first(4))
    .where('events.arg2': TargetInvestor::STAGES.keys.drop(4))
  target_investors = founder.target_investors.where('target_investors.stage > 3')

  total_decided = 0.0
  total_events = events.count('DISTINCT events.subject_id').to_f

  datapoints = (0..18).map do |i|
    start = first_target_on + i.weeks
    finish = start + 1.week

    total_decided += events
      .where('events.created_at >= ?', start)
      .where('events.created_at < ?', finish)
      .count('DISTINCT events.subject_id')
    decided_ratio = [total_decided / total_events, 1.0].min

    [i, decided_ratio]
  end

  puts datapoints.to_s
  datapoints
end.compact

puts dataset.first(5).to_s

save_data dataset, :decided_over_weeks
