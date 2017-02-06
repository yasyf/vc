module Http::Crunchbase
  class Organization
    extend Concerns::Cacheable

    INVALID_KEY = '_invalid_magic_cb_org_key'
    SIGNAL_INVESTORS = ['Dorm Room Fund', 'Rough Draft Ventures']

    include HTTParty
    base_uri 'https://api.crunchbase.com/v/3/organizations'
    format :json
    headers 'Content-Type': 'application/json'
    default_params user_key: ENV['CB_API_KEY']

    def initialize(company, timeout = nil)
      @company = company
      @timeout = timeout
    end

    def permalink
      get_in 'properties', 'permalink'
    end

    def description
      get_in 'properties', 'short_description'
    end

    def url
      get_in 'properties', 'homepage_url'
    end

    def crunchbase_url
      path = get_in 'properties', 'web_path'
      "https://www.crunchbase.com/#{path}"
    end

    def investors
      get_in 'relationships', 'investors', multi: true
    end

    def twitter
      twitter = websites&.find { |site| site['properties']['website_type'] == 'twitter' }
      url = twitter['properties']['url'].split('/') if twitter.present?
      url.last if url.present? && url.length > 3
    end

    def has_investor?(name)
      investors&.find { |inv| inv['properties']['name'] == name || inv['properties']['permalink'] == name }.present?
    end

    def total_funding
      get_in 'properties', 'total_funding_usd'
    end

    def self.find_investor_id(name)
      result = api_get("/", name: name, organization_types: 'investor').first
      result && result['properties']['permalink']
    end

    private

    def websites
      get_in 'relationships', 'websites', multi: true
    end

    def self.api_get(raw_path, query = {}, multi = true)
      path = URI.encode raw_path
      data = key_cached(query.merge(path: path)) do
        response = get(path, query: query)
        case response.code
        when 200
          response.parsed_response['data']
        when 404
          nil
        when 401
          Rails.logger.warn "Crunchbase 401: #{path}/#{query}"
          nil
        else
          raise "Crunchbase #{response.code}: #{path}/#{query}"
        end
      end
      multi ? (data && data['items']) || [] : data
    end

    def self.base_cache_key
      "http/crunchbase/organizations"
    end

    def get_in_raw(path, multi)
      return nil unless found?
      current = search
      current = current[path.shift] while path.present?
      multi ? current['items'] : current
    end

    def get_in(*path, multi: false)
      if @timeout.present?
        Timeout::timeout(@timeout) { get_in_raw(path, multi) }
      else
        get_in_raw(path, multi)
      end
    rescue Timeout::Error, JSON::ParserError # when we hit rate limiting
      multi ? [] : nil
    end

    def found?
      search.present?
    end

    def search
      @search ||= begin
        data = fetch_data
        if company_id.present? && id_valid?
          data
        elsif data.present?
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
      @company_id ||= @company.crunchbase_id unless !id_valid?
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
