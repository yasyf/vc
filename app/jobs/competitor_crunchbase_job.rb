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
        funding_round = investment['relationships']['funding_round']
        next unless funding_round.present?
        company = funding_round['relationships']['funded_organization']
        retry_record_errors do
          c = Company.where(crunchbase_id: company['properties']['permalink']).first_or_create! do |c|
            c.name = company['properties']['name']
          end
          c.competitors << competitor
          c.save! if c.changed?
        end
      end
    end
  end
end
