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
      bio = get_in('properties', 'bio')
      bio.split('.').first + '.' if bio.present?
    end

    def affiliation
      return nil unless found?
      @affiliation ||= begin
        aff = get_in 'relationships', 'primary_affiliation'
        aff = aff['item'] if aff.present?
        org =  aff['relationships']['organization'] if aff.present?
        OpenStruct.new({
          role: aff['properties']['title'],
          name: org['properties']['name'],
          permalink: org['properties']['permalink'],
        }) if aff.present? && org.present?
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
