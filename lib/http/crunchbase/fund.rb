module Http::Crunchbase
  class Fund < Base
    base_uri 'https://api.crunchbase.com/v3.1/organizations'

    def initialize(permalink, timeout = nil, raise_on_error = true)
      @permalink = permalink
      super timeout, raise_on_error
    end

    def description
      get_in 'properties', 'description'
    end

    def team
      get_in 'relationships', 'featured_team', multi: true
    end

    def locations
      offices = get_in 'relationships', 'offices', multi: true
      return [] unless offices.present?
      offices.map { |office| office['properties']['city'] }
    end

    def country
      code = get_in('relationships', 'headquarters', 'item', 'properties', 'country_code2')
      return code if code.present?
      name = get_in('relationships', 'headquarters', 'item', 'properties', 'country')
      Country.find_country_by_name(name)&.alpha2 if name.present?
    end

    def found?
      @permalink.present? && super
    end

    def investments(deep: false)
      if deep && found?
        self.class.api_get("/#{@permalink}/investments")
      else
        get_in 'relationships', 'investments', multi: true
      end
    end

    private

    def self.base_cache_key
      'http/crunchbase/fund'
    end

    def search_for_data
      @search ||= self.class.api_get("/#{@permalink}", {}, false)
    end
  end
end
