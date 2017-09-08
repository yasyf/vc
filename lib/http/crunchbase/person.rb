module Http::Crunchbase
  class Person < Base
    base_uri 'https://api.crunchbase.com/v3.1/people'

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

    def bio
      get_in 'properties', 'bio'
    end

    def image
      get_in 'properties', 'profile_image_url'
    end

    def gender
      gender = get_in('properties', 'gender')
      return nil unless gender.present?
      gender.downcase.to_sym.in?(Investor::GENDERS) ? gender.downcase : nil
    end

    def short_bio
      bio.split('.').first + '.' if bio.present?
    end

    def blog
      site = website_of_type('blog')
      site['properties']['url'] if site.present?
    end

    def university
      degrees = get_in 'relationships', 'degrees', multi: true
      return nil unless degrees.present?
      degrees.last['relationships']['school']['properties']['name']
    end

    def affiliated_companies
      %w(jobs advisory_roles).flat_map do |field|
        jobs = get_in 'relationships', field, multi: true
        if jobs.present?
          jobs.map { |job| job['relationships']['organization']['properties'].slice('name', 'permalink') }
        else
          []
        end
      end
    end

    def affiliation
      return nil unless found?
      @affiliation ||= begin
        aff = get_in 'relationships', 'primary_affiliation'
        aff = aff['item'] if aff.present?
        org =  aff['relationships']['organization'] if aff.present? && aff['relationships'].present?
        OpenStruct.new({
          role: aff['properties']['title'],
          name: org['properties']['name'],
          permalink: org['properties']['permalink'],
        }) if aff.present? && org.present?
      end
    end

    def location
      return nil unless found?
      @location ||= begin
        loc = get_in 'relationships', 'primary_location'
        loc = loc['item'] if loc.present?
        loc = loc['properties'] if loc.present?
        OpenStruct.new(loc) if loc.present?
      end
    end

    def self.find_investor_id(name)
      find_id(name: name)
    end

    private

    def self.base_cache_key
      "http/crunchbase/people"
    end

    def search_for_data
      @search ||= self.class.api_get("/#{@permalink}", {}, false)
    end
  end
end
