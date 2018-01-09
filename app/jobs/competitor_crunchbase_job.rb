class CompetitorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  FUND_TYPE_KEYWORDS = {
    seed: %w(seed),
    preseed: %w(pre-seed preseed),
    accelerator: %w(accelerator),
    angel: %w(angel),
  }

  queue_as :default

  def perform(competitor_id)
    competitor = Competitor.find(competitor_id)

    competitor.crunchbase_id ||= Http::Crunchbase::Organization.find_investor_id(competitor.name)
    begin
      competitor.save!
    rescue ActiveRecord::RecordInvalid => e
      DuplicateCompetitorJob.perform_later competitor.id
      return
    end

    competitor.al_id ||= Http::AngelList::Startup.find_id(competitor.name, cb_id: competitor.crunchbase_id)
    begin
      competitor.save!
    rescue ActiveRecord::RecordInvalid => e
      Competitor.where(al_id: competitor.al_id).update_all al_id: nil
      competitor.save!
    end

    cb_fund = competitor.crunchbase_fund
    al_fund = competitor.angellist_startup

    competitor.description ||= cb_fund.description || al_fund.description
    competitor.location = (competitor.location || []) + (al_fund.locations || []) + (cb_fund.locations || [])
    competitor.hq = cb_fund.hq
    competitor.country = cb_fund.country
    competitor.photo = al_fund.logo || cb_fund.image
    competitor.facebook = al_fund.facebook || cb_fund.facebook
    competitor.twitter = al_fund.twitter || cb_fund.twitter
    competitor.domain = al_fund.url || cb_fund.url
    competitor.al_url = al_fund.angellist_url
    competitor.fund_type = (competitor.fund_type || []) + cb_fund.fund_types
    competitor.save! if competitor.changed?

    if competitor.description.present?
      FUND_TYPE_KEYWORDS.each do |fund_type, keywords|
        if keywords.any? { |w| competitor.description.downcase.include?(w) } && !competitor.fund_type.include?(fund_type.to_s)
          competitor.fund_type << fund_type.to_s
        end
      end
    end

    if (team = cb_fund.team).present?
      team.each do |job|
        next if Competitor::NON_INVESTOR_TITLE.any? { |t| job.title.downcase.include?(t) }
        next unless (person = job.person).present?
        investor = Investor.from_crunchbase(person.permalink)
        if investor.present?
          next unless investor.competitor != competitor
          begin
            investor.update! competitor: competitor, role: job.title, description: person.bio
          rescue ActiveRecord::RecordInvalid
            other = competitor.investors.where(first_name: investor.first_name, last_name: investor.last_name).first!
            investor.update! crunchbase_id: nil
            other.update! crunchbase_id: person.permalink
            investor.destroy!
            InvestorCrunchbaseJob.perform_later(other.id)
          else
            InvestorCrunchbaseJob.perform_later(investor.id)
          end
        else
         investor = competitor.investors.where(first_name: person.first_name, last_name: person.last_name).first
         next unless investor.present?
         investor.update! crunchbase_id: person.permalink
         InvestorCrunchbaseJob.perform_later(investor.id)
        end
      end
    end

    al_fund.roles.each do |person|
      Investor.from_angelist(person['id'])
    end

    if (investments = cb_fund.investments(deep: true)).present?
      investments.each do |investment|
        partners = investment.partners.map do |partner|
          Investor.from_crunchbase(partner.permalink)
        end
        funding_round = investment.funding_round
        company = funding_round&.funded_organization
        next unless funding_round.present? && company.present?
        retry_record_errors do
          c = Company.where(crunchbase_id: company.permalink).first_or_create! do |c|
            c.name = company.name
          end
          cc = c.investments.where(competitor: competitor).first_or_initialize
          cc.funded_at = (investment.announced_on || funding_round.announced_on).to_date
          cc.funding_type = funding_round.funding_type
          cc.series = funding_round.series
          cc.round_size = funding_round.money_raised_usd
          if partners.present? && (investor = partners.first).present?
            cc.investor = investor
            cc.featured = true
          end
          cc.save! if cc.changed?
        end
      end
    end

    al_fund.investments.each do |investment|
      startup = investment['startup']
      next unless startup.present?
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
