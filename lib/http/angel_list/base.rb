module Http::AngelList
  class Base
    extend Concerns::Cacheable

    include HTTParty
    base_uri 'https://api.angel.co/1'
    format :json
    headers 'Content-Type': 'application/json'

    def initialize(id_or_slug, timeout: nil)
      @timeout = timeout
      @id_or_slug = id_or_slug
      fetch! if false # id_or_slug.present?
    end

    def self.resource
      self.name.demodulize.downcase
    end

    def self.find_id(query, org: nil, cb_id: nil)
      results = api_get('/search', query: query, type: resource.titleize)
      filtered = results.select do |r|
        result = new(r['id'])
        (
          r['name']&.strip&.downcase == query.downcase &&
          (org.blank? || result.description.downcase.include?(org.downcase)) &&
          (cb_id.blank? || result.crunchbase&.downcase&.strip == cb_id.downcase.strip)
        )
      end.compact
      filtered.present? ? filtered.first['id'] : nil
    end

    def self.search(query)
      id = find_id query
      self.new(id) if id.present?
    end

    def found?
      return false # TODO: re-enable AL API
      @data.present? && @data['id'].present?
    end

    def roles
      return [] unless found?
      @roles ||= fetch_roles! || []
    end

    def id
      @data['id'] if found?
    end

    def angellist_url
      @data['angellist_url'] if found?
    end

    def name
      @data['name'] if found?
    end

    def blog
      @data['blog_url'] if found?
    end

    def twitter
      url = @data['twitter_url'] if found?
      url.split('/').last if url.present?
    end

    def facebook
      url = @data['facebook_url'] if found?
      url.split('/').last if url.present?
    end

    def linkedin
      return nil unless found? && @data['linkedin_url'].present?
      @data['linkedin_url'].split('/').drop(4).join('/')
    end

    def crunchbase
      url = @data['crunchbase_url'] if found?
      url.split(/\/|\%2F/).last if url.present?
    end

    def locations
      return [] unless found? && @data['locations'].present?
      @locations ||= @data['locations'].map { |l| l['display_name'] }
    end

    private

    def fetch_roles!(query = {})
      roles = self.class.api_get("/#{self.class.resource.pluralize}/#{@id_or_slug}/roles", query)
      roles['startup_roles'] if roles.present?
    end

    def fetch!
      if @id_or_slug.is_a?(Integer)
        @data = self.class.api_get("/#{self.class.resource.pluralize}/#{@id_or_slug}")
      else
        @data = self.class.api_get("/#{self.class.resource.pluralize}/search", slug: @id_or_slug)
      end
    end

    def self.base_cache_key
      "http/angelist/#{resource}"
    end

    def self.next_token
      ENV['AL_API_KEY'].split(',').sample
    end

    def self._api_get(path, query)
      key_cached(query.merge(path: path)) do
        Retriable.retriable(on: Errors::APIError) do
          response = get(path, query: query.merge(access_token: next_token))
          raise Errors::APIError.new(response.code) if response.code.to_s.starts_with?('5')
          parsed = response.parsed_response
          if response.code == 404
            nil
          elsif response.code == 403
            raise Errors::RateLimited.new(parsed)
          elsif parsed.is_a?(Hash) && parsed['error'].present?
            raise Errors::APIError.new(parsed['error'])
          else
            response.parsed_response
          end
        end
      end
    rescue Timeout::Error
      raise Errors::Timeout.new(path)
    end

    def self.api_get(path, query = {})
      _api_get(path, query)
    end
  end
end
