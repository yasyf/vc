module Http::Crunchbase
  class Fund < Base
    base_uri 'https://api.crunchbase.com/v3.1/organizations'

    def initialize(permalink, timeout = nil)
      @permalink = permalink
      super timeout
    end

    def description
      get_in 'properties', 'description'
    end

    def team
      get_in 'relationships', 'featured_team', multi: true
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
      "http/crunchbase/fund"
    end

    def search_for_data
      @search ||= self.class.api_get("/#{@permalink}", {}, false)
    end
  end
end
