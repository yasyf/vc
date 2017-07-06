module Http::Crunchbase
  class Person < Base
    base_uri 'https://api.crunchbase.com/v/3/people'

    def initialize(permalink, timeout = nil)
      @permalink = permalink
      super timeout
    end

    def first_name
      get_in 'properties', 'first_name'
    end

    def last_name
      get_in 'properties', 'last_name'
    end

    private

    def self.base_cache_key
      "http/crunchbase/peeople"
    end

    def search_for_data
      @search ||= self.class.api_get("/#{@permalink}", {}, false)
    end
  end
end
