class CompetitorCrunchbaseJob < ApplicationJob
  queue_as :default

  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)
    fund = competitor.crunchbase_fund

    description = fund.short_description
    competitor.description = description if description.present?
    competitor.save! if competitor.changed?

    fund.team.each do |job|
      Investor.from_crunchbase( job['relationships']['person']['properties']['permalink'])
    end
  end
end
