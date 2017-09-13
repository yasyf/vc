class CompetitorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  INVESTOR_TITLE = ['Venture Partner', 'Managing Partner', 'Partner', 'Analyst', 'Associate']

  queue_as :default

  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)

    competitor.crunchbase_id ||= Http::Crunchbase::Organization.find_investor_id(competitor.name)
    competitor.al_id ||= Http::AngelList::Startup.find_id(competitor.name)

    begin
      competitor.save!
    rescue ActiveRecord::RecordInvalid => e
      raise unless e.record.errors.details.all? { |k,v| v.all? { |e| e[:error].to_sym == :taken } }
      DuplicateCompetitorJob.perform_later competitor.id
      return
    end

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
      next unless person['role'] == 'founder' || INVESTOR_TITLE.include?(person['title']&.titleize)
      Investor.from_angelist(person['id'])
    end

    if (investments = cb_fund.investments(deep: true)).present?
      investments.each do |investment|
        next unless investment['relationships'].present?
        partners = investment['relationships']['partners'].map do |partner|
          Investor.from_crunchbase(partner['properties']['permalink'])
        end
        funding_round = investment['relationships']['funding_round']
        next unless funding_round.present? && funding_round['relationships'].present?
        company = funding_round['relationships']['funded_organization']
        retry_record_errors do
          c = Company.where(crunchbase_id: company['properties']['permalink']).first_or_create! do |c|
            c.name = company['properties']['name']
          end

          cc = c.investments.where(competitor: competitor).first_or_initialize
          cc.funded_at = (investment['properties']['announced_on'] || funding_round['properties']['announced_on']).to_date
          cc.funding_type = funding_round['properties']['funding_type']
          cc.series = funding_round['properties']['series']
          cc.round_size = funding_round['properties']['money_raised_usd']
          if partners.present?
            cc.investor = partners.first
            cc.featured = true
          end
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

        c.investments.where(competitor: competitor).first_or_create!
      end
    end
  end
end
