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
      get_in 'properties', 'name'
    end

    def description
      get_in 'properties', 'short_description'
    end

    def url
      get_in 'properties', 'homepage_url'
    end

    def investors
      get_in 'relationships', 'investors', multi: true
    end

    def founders
      get_in 'relationships', 'founders', multi: true
    end

    def board_members_and_advisors
      get_in 'relationships', 'board_members_and_advisors', multi: true
    end

    def funding_rounds
      get_in 'relationships', 'funding_rounds', multi: true
    end

    def categories
      get_in 'relationships', 'categories', multi: true
    end

    def has_investor?(name)
      investors&.find { |inv| inv['properties']['name'] == name || inv['properties']['permalink'] == name }.present?
    end

    def total_funding
      get_in 'properties', 'total_funding_usd'
    end

    def self.find_investor_id(name)
      find_id(name: name, organization_types: 'investor')
    end

    def self.find_domain_id(domain, types: 'investor')
      find_id(domain_name: domain, organization_types: types)
    end

    private

    def self.base_cache_key
      "http/crunchbase/organizations"
    end

    def search_for_data
      @search ||= begin
        data = fetch_data
        if company_id.present? && id_valid?
          data
        elsif data.present? && data['properties'].present?
          self.class.api_get("/#{data['properties']['permalink']}", {}, false)
        end
      end
    end

    def fetch_from_name(try_guess)
      by_name = self.class.api_get("/", name: @company.name)
      if (
        by_name.size == 1 &&
        by_name.first['properties']['primary_role'] == 'company' &&
        Levenshtein.distance(by_name.first['properties']['name'].downcase, @company.name.downcase) <= 3
      )
        return by_name.first if try_guess
        investors = self.class.api_get("/#{by_name.first['properties']['permalink']}/investors")
        return by_name.first if investors&.find { |inv| SIGNAL_INVESTORS.include?(inv['properties']['name']) }.present?
      end

      return nil unless try_guess

      if by_name.size <= 3
        from_name = self.class.api_get("/#{@company.param_name}", {}, false)
        from_name_check = self.class.api_get("/#{@company.param_name}-2", {}, false)
        return from_name if from_name.present? && from_name_check.blank?
      end

      by_name.find do |company_data|
        investors = self.class.api_get("/#{company_data['properties']['permalink']}/investors")
        investors&.find { |inv| SIGNAL_INVESTORS.include?(inv['properties']['name']) }.present?
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
        data = self.class.api_get("/", domain_name: @company.domain).first
        return data if data.present?
      end
      fetch_from_name(id_valid?)
    end
  end
end
