module Http::Crunchbase
  class Person < Base
    base_uri 'https://api.crunchbase.com/v3.1/people'

    def initialize(permalink, timeout = nil, raise_on_error = true)
      @permalink = permalink
      super timeout, raise_on_error
    end

    def first_name
     response.first_name
    end

    def last_name
     response.last_name
    end

    def bio
      bio = response.bio
      self.class.markdown.render(Util.fix_encoding(bio)) if bio.present?
    end

    def gender
      gender = response.gender
      return nil unless gender.present?
      gender.downcase.to_sym.in?(Investor::GENDERS) ? gender.downcase : nil
    end

    def short_bio
      bio.split('.').first + '.' if bio.present?
    end

    def blog
      site = website_of_type('blog')
      site.url if site.present?
    end

    def university
      response.degrees&.last&.school&.name
    end

    def affiliated_companies
      %w(jobs advisory_roles).flat_map do |field|
        response.rel(field).map { |job| job.organization&.properties&.slice('name', 'permalink') }.compact
      end
    end

    def affiliation
      return nil unless (org = response.primary_affiliation&.organization).present?
      @affiliation ||= begin
        OpenStruct.new({role: org.title, name: org.name, permalink: org.permalink})
      end
    end

    def location
      return nil unless found? && response.primary_location.present?
      @location ||= begin
        OpenStruct.new(response.primary_location.properties)
      end
    end

    def self.find_investor_id(name, org = nil)
      results = api_get('/', name: name.gsub('&') { '\\&' }, types: 'investor')
      (org ? results.find { |r| r.organization_name.downcase == org.downcase } : results.first)&.permalink
    end

    private

    def self.base_cache_key
      'http/crunchbase/people'
    end

    def search_for_data
      @search ||= self.class.api_get("/#{@permalink}", {}, false)
    end
  end
end
