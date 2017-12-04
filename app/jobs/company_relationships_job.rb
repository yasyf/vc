class CompanyRelationshipsJob < ApplicationJob
  include Concerns::Ignorable

  TIMEOUT = 5

  queue_as :default

  def perform(company_id)
    @company = Company.find(company_id)

    @company.al_id ||= Http::AngelList::Startup.find_id(@company.name)
    @al_startup = @company.angelist_startup(TIMEOUT)

    @company.crunchbase_id ||= Http::Crunchbase::Organization.find_domain_id(@company.domain, types: 'company')
    @company.crunchbase_id ||= @al_startup.crunchbase
    @cb_org = @company.crunchbase_org(TIMEOUT, raise_on_error: true)

    if @al_startup.crunchbase != @company.crunchbase_id
      @company.al_id = nil
      @al_startup = Http::AngelList::Startup.new(nil)
    end

    @company.set_extra_attributes!

    categories = @cb_org.categories
    @company.industry = categories
                          .map { |c| c['properties']['name'] }
                          .compact
                          .map { |i| Competitor.closest_industry(i) }
                          .compact
                          .uniq if categories.present?

    @company.industry = (@company.industry || []) + @al_startup.markets

    begin
      ignore_invalid { @company.save! } if @company.changed?
    rescue *unique_errors
      attrs = @company.errors.details.map { |k,_| [k, @company.send(k)] }.to_h
      DuplicateCompanyJob.perform_later(@company.id, attrs)
      return
    end

    if @cb_org.found?
      add_cb_founders
      add_cb_investors
    end

    if @al_startup.found?
      add_al_founders
      add_al_investors
    end
  end

  private

  def add_al_founders
    @al_startup.roles.each do |person|
      next unless person['role'] == 'founder'
      user = Http::AngelList::User.new person['tagged']['id']
      social = Founder::SOCIAL_KEYS.map { |k| [k, user.public_send(k)] }.to_h
      next unless user.name.present?
      name = user.name.split(/[\s.]/).map(&:titleize)
      next unless name.length > 1
      ignore_record_errors do
        founder = Founder.find_or_create_from_social!(name.first, name.drop(1).join(' '), social, context: @company)
        founder.tap { |f| f.companies << @company }.save! if founder.present?
      end
    end
  end

  def add_al_investors
    @al_startup.roles.each do |person|
      next unless person['role'] == 'past_investor' && person['tagged']['type'] == 'Startup'
      ignore_invalid do
        competitor = Competitor.from_angelist! person['tagged']['id'], person['tagged']['name']
        competitor.investments.where(company: @company).first_or_create!
      end
    end
  end

  def add_cb_founders
    return unless (founders = @cb_org.founders).present?
    founders.each do |founder|
      next unless founder['properties'].present?
      person = Http::Crunchbase::Person.new(founder['properties']['permalink'], TIMEOUT)
      next unless person.found?
      social = Founder::SOCIAL_KEYS.map { |k| [k, person.public_send(k)] }.to_h
      ignore_record_errors do
        founder = Founder.find_or_create_from_social!(person.first_name, person.last_name, social, context: @company)
        founder.tap { |f| f.companies << @company }.save! if founder.present?
      end
    end
  end

  def add_cb_investors
    @cb_org.investors.each do |competitor|
      next if competitor['type'] == 'Person'
      ignore_invalid do
        competitor = Competitor.from_crunchbase! competitor['properties']['permalink'], competitor['properties']['name']
        competitor.investments.where(company: @company).first_or_create!
      end
    end

    @cb_org.funding_rounds.each do |funding_round|
      next unless funding_round['relationships'].present?
      funding_round['relationships']['investments'].each do |investment|
        investor = investment['relationships']['investors']
        next unless investor.present?
        next if investor['type'] == 'Person'
        partner = investment['relationships']['partners'].first
        competitor = Competitor.from_crunchbase! investor['properties']['permalink'], investor['properties']['name']
        cc = competitor.investments.where(company: @company).first_or_initialize
        cc.funded_at = (investment['properties']['announced_on'] || funding_round['properties']['announced_on']).to_date
        cc.funding_type = funding_round['properties']['funding_type']
        cc.series = funding_round['properties']['series']
        cc.round_size = funding_round['properties']['money_raised_usd']
        if partner.present? && (investor = Investor.from_crunchbase(partner['properties']['permalink'])).present?
          cc.investor = investor
          cc.featured = true
        end
        cc.save! if cc.changed?
      end
    end

    @cb_org.board_members_and_advisors.each do |person|
      id = person['relationships']['person']['properties']['permalink']
      competitor = competitor_from_person_id(id)
      next unless competitor.present? && (cc = competitor.investments.where(company: @company).first).present?
      if (investor = Investor.from_crunchbase(id)).present?
        cc.update! investor: investor, featured: true
      end
    end

    news = @cb_org.news.map { |n| [n['url'], n] }.to_h
    Http::Fetch.get(news.keys).each do |url, body|
      next unless body.present?
      ignore_invalid { import_news(url, body, news[url]['posted_on']) }
    end
  end

  def competitor_from_person_id(id)
    details = Http::Crunchbase::Person.new(id, TIMEOUT)
    return nil unless details.affiliation.permalink.present?
    Retriable.retriable(on: NoMethodError) { Competitor.where(crunchbase_id: details.affiliation.permalink).first }
  rescue NoMethodError
    nil
  end

  def import_news(url, body, published_at)
    @company.investments.where(investor_id: nil).find_each do |cc|
      destroy_invalid_investments!(cc.competitor_id) and next unless (competitor = cc.competitor).present?
      competitor.investors.find_each do |investor|
        if body.include?(investor.name)
          cc.update! investor: investor unless cc.investor.present?
          News.create_with_body(url, body, investor: investor, company: @company, attrs: { published_at: published_at })
          break
        end
      end
    end
    News.create_with_body(url, body, investor: nil, company: @company)
  end

  def destroy_invalid_investments!(competitor_id)
    Rails.logger.error "[destroy_invalid_investments] #{competitor_id}"
    Investment.where(competitor_id: competitor_id).destroy_all
  end
end
