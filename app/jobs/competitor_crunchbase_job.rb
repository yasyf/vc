class CompetitorCrunchbaseJob < ApplicationJob
  queue_as :default

  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)
    description = competitor.crunchbase_fund.short_description
    competitor.description = description if description.present?
    competitor.save! if competitor.changed?
  end
end
