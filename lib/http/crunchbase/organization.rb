module Http::Crunchbase
  class Organization < Base
    INVALID_KEY = '_invalid_magic_cb_org_key'
    SIGNAL_INVESTORS = ['Dorm Room Fund', 'Rough Draft Ventures']

    base_uri 'https://api.crunchbase.com/v3.1/organizations'

    def initialize(company, timeout = nil, raise_on_error = true)
      @company = company
      super timeout, raise_on_error
    end

    def name
     response.name
    end

    def description
      Util.fix_encoding(response.short_description)
    end

    def investors
      response.investors
    end

    def founders
      response.founders
    end

    def board_members_and_advisors
      response.board_members_and_advisors
    end

    def funding_rounds
      response.funding_rounds
    end

    def categories
      response.categories
    end

    def has_investor?(name)
      investors.any? { |inv| inv.name == name || inv.permalink == name }
    end

    def total_funding
     response.total_funding_usd
    end

    def location
      response.headquarters.city
    end

    def self.find_investor_id(name)
      find_id(name: name.gsub('&') { '\\&' }, organization_types: 'investor')
    end

    def self.find_domain_id(domain, types: 'investor')
      find_id(domain_name: domain, organization_types: types)
    end

    private

    def self.base_cache_key
      'http/crunchbase/organizations'
    end

    def search_for_data
      @search ||= begin
        data = fetch_data
        if company_id.present? && id_valid?
          data
        elsif data.present?
          self.class.api_get("/#{data.permalink}", {}, false)
        end
      end
    end

    def fetch_from_name(try_guess)
      by_name = self.class.api_get('/', name: @company.name)
      if (
        by_name.size == 1 &&
        by_name.first.primary_role == 'company' &&
        by_name.first.name.strip.downcase == @company.name.downcase
      )
        return by_name.first if try_guess
        investors = self.class.api_get("/#{by_name.first.permalink}/investors")
        return by_name.first if investors&.find { |inv| SIGNAL_INVESTORS.include?(inv.name) }.present?
      end

      return nil unless try_guess

      if by_name.size <= 3
        from_name = self.class.api_get("/#{@company.param_name}", {}, false)
        from_name_check = self.class.api_get("/#{@company.param_name}-2", {}, false)
        return from_name if from_name.present? && from_name_check.blank?
      end

      by_name.find do |company_data|
        investors = self.class.api_get("/#{company_data.permalink}/investors")
        investors&.find { |inv| SIGNAL_INVESTORS.include?(inv.name) }.present?
      end
    end

    def id_valid?
      @id_valid ||= @company.crunchbase_id.blank? || !@company.crunchbase_id.starts_with?(INVALID_KEY)
    end

    def company_id
      @company_id ||= @company.crunchbase_id if id_valid?
    end

    def fetch_data
      if company_id.present? && id_valid?
        return self.class.api_get("/#{company_id}", {}, false)
      end
      if @company.domain.present?
        data = self.class.api_get('/', domain_name: @company.domain).first
        return data if data.present?
      end
      fetch_from_name(id_valid?)
    end
  end
end
