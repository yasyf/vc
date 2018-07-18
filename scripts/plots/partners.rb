require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative './plot_helpers'

include PlotHelpers

competitors = Competitor
  .joins("INNER JOIN competitor_partners ON competitor_partners.competitor_id = competitors.id")
  .select('competitors.id', 'json_array_length(competitor_partners.partners) AS num_partners')

dataset = parallel_map(competitors) { |competitor| competitor.num_partners }.compact

puts dataset.size, dataset.first(5).to_s
save_data dataset, :partners
