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

    def short_bio
      get_in('properties', 'bio').split('.').first + '.'
    end

    def affiliation
      @affiliation ||= begin
        aff = get_in 'relationships', 'primary_affiliation'
        OpenStruct.new({
          role: aff['item']['properties']['title'],
          name: aff['item']['relationships']['organization']['properties']['name'],
          permalink: aff['item']['relationships']['organization']['properties']['permalink'],
        }) if aff.present?
      end
    end

    def self.find_investor_id(name)
      find_id(name: name)
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
