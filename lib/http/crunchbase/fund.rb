module Http::Crunchbase
  class Fund < Base
    base_uri 'https://api.crunchbase.com/v/3/organizations'

    def initialize(permalink, timeout = nil)
      @permalink = permalink
      super timeout
    end

    def short_description
      get_in 'properties', 'short_description'
    end

    def team
      get_in 'relationships', 'featured_team', multi: true
    end

    def investments
      get_in 'relationships', 'investments', multi: true
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
