class CompetitorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :default

  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)
    fund = competitor.crunchbase_fund

    description = fund.short_description
    competitor.description = description if description.present?
    competitor.save! if competitor.changed?

    if (team = fund.team).present?
      team.each do |job|
        Investor.from_crunchbase( job['relationships']['person']['properties']['permalink'])
      end
    end

    if (investments = fund.investments).present?
      investments.each do |investment|
        company = investment['relationships']['funding_round']['relationships']['funded_organization']
        ignore_unique do
          Company.where(crunchbase_id: company['properties']['permalink']).first_or_create! do |c|
            c.name = company['properties']['name']
            c.competitors << competitor
          end
        end
      end
    end
  end
end
