require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative './plot_helpers'

include ActionView::Helpers::DateHelper
include PlotHelpers

raised_for, dataset = parallel_map(fundraised_founders) do |founder|
  first_target_on, last_target_change = fundraising_range founder

  difference = TimeDifference.between(first_target_on, last_target_change)
  next if difference.in_months < 1

  events = founder
    .target_investors.joins(:events)
    .where('events.action': :state_changed)
    .where('events.arg1': TargetInvestor::STAGES.keys.first(4))
    .where('events.arg2': ["4_pitch", "5_interested"])

  next if events.count == 0

  target_investors = founder.target_investors.where('target_investors.stage = 4 OR target_investors.stage = 5')
  emails = fundraising_emails founder

  total_emails = emails
    .where('emails.created_at >= ?', first_target_on)
    .where('emails.created_at <= ?', last_target_change)
    .count
    .to_f
  next if total_emails == 0

  total_decided = 0.0
  total_events = events.count('DISTINCT events.subject_id').to_f
  weeks = difference.in_weeks.ceil

  datapoints = (0..weeks).map do |i|
    start = first_target_on + i.weeks
    finish = start + 1.week

    total_decided += events
      .where('events.created_at >= ?', start)
      .where('events.created_at < ?', finish)
      .count('DISTINCT events.subject_id')
    decided_ratio = [total_decided / total_events, 1.0].min

    email_count = emails
      .where('emails.created_at >= ?', start)
      .where('emails.created_at < ?', finish)
      .count
    emails_ratio = email_count.to_f / total_emails

    [i, decided_ratio, emails_ratio] # week, proportion decided, emails for the week
  end

  puts datapoints.to_s
  [difference.in_months, datapoints]
end.compact.transpose

puts raised_for.sum / raised_for.size
puts dataset.first(5).to_s

save_data dataset, :email_volume_over_decisions
