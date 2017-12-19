module Http::Crunchbase
  class Fund < Base
    base_uri 'https://api.crunchbase.com/v3.1/organizations'

    TYPES = {
      accelerator: :accelerator,
      incubator: :accelerator,
      venture_capital: :venture,
      micro_vc: :preseed,
      angel_group: :angel,
    }

    def initialize(permalink, timeout = nil, raise_on_error = true)
      @permalink = permalink
      super timeout, raise_on_error
    end

    def description
      Util.fix_encoding(response.description)
    end

    def team
      response.featured_team || []
    end

    def locations
      response.offices&.map(&:city) || []
    end

    def hq
      response.headquarters&.city
    end

    def country
      code = response.headquarters&.country_code2
      return code if code.present?
      name = response.headquarters&.country
      Country.find_country_by_name(name)&.alpha2 if name.present?
    end

    def found?
      @permalink.present? && super
    end

    def investments(deep: false)
      if deep && found?
        self.class.api_get("/#{@permalink}/investments")
      else
        response.investments || []
      end
    end

    def fund_types
      (response.investor_type || []).map { |t| TYPES[t.to_sym] }.compact
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
