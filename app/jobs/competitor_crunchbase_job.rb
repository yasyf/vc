class CompetitorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  INVESTOR_TITLE = ['Venture Partner', 'Managing Partner', 'Partner', 'Analyst', 'Associate']

  queue_as :default

  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)

    competitor.crunchbase_id ||= Http::Crunchbase::Organization.find_investor_id(competitor.name)
    competitor.al_id ||= Http::AngelList::Startup.find_id(competitor.name)

    cb_fund = competitor.crunchbase_fund
    al_fund = competitor.angellist_startup

    competitor.description ||= cb_fund.description || al_fund.description
    if al_fund.locations.present?
      competitor.location = (competitor.location || []) + al_fund.locations
    end
    competitor.save! if competitor.changed?

    if (team = cb_fund.team).present?
      team.each do |job|
        Investor.from_crunchbase( job['relationships']['person']['properties']['permalink'])
      end
    end

    al_fund.roles.each do |person|
      next unless person['role'] == 'founder' || person['title'].titleize.in?(INVESTOR_TITLE)
      Investor.from_angelist(person['id'])
    end

    if (investments = cb_fund.investments).present?
      investments.each do |investment|
        funding_round = investment['relationships']['funding_round']
        next unless funding_round.present? && funding_round['relationships'].present?
        company = funding_round['relationships']['funded_organization']
        retry_record_errors do
          c = Company.where(crunchbase_id: company['properties']['permalink']).first_or_create! do |c|
            c.name = company['properties']['name']
          end

          cc = c.companies_competitors.where(competitor: competitor).first_or_initialize
          cc.funded_at ||= funding_round['properties']['announced_on'].to_date
          cc.save! if cc.changed?
        end
      end
    end

    al_fund.investments.each do |investment|
      startup = investment['startup']
      retry_record_errors do
        c = Company.where(al_id: startup['id']).first_or_create! do |c|
          c.name = startup['name']
          c.domain = startup['company_url']
        end

        cc = c.companies_competitors.where(competitor: competitor).first_or_initialize
        cc.funded_at ||= investment['created_at'].to_date
        cc.save! if cc.changed?
      end
    end
  end
end
