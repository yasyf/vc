module Http::AngelList
  class User
    extend Concerns::Cacheable

    ROLES = {
      'seed funds' => :seed,
      'angels' => :angel,
      'vc' => :vc,
    }

    include HTTParty
    base_uri 'https://api.angel.co/1'
    format :json
    headers 'Content-Type': 'application/json'
    default_params access_token: ENV['AL_API_KEY']

    def initialize(id_or_slug, timeout: nil)
      raise 'missing id or slug!' unless id_or_slug.present?
      @timeout = timeout
      @id_or_slug = id_or_slug
      fetch!
    end

    def self.find_investor_id(query)
      results = api_get('/search', query: query, type: 'User')
      results.first['id'] if results.present?
    end

    def self.search(query)
      id = find_investor_id query
      self.new(id) if id.present?
    end

    def found?
      @data.present?
    end

    def id
      @data['id'] if found?
    end


    def name
      @data['name'] if found?
    end

    def image
      @data['image'] if found?
    end

    def blog
      @data['blog_url'] if found?
    end

    def homepage
      @data['online_bio_url'] if found?
    end

    def twitter
      @data['twitter_url'].split('/').last if found?
    end

    def facebook
      @data['facebook_url'].split('/').last if found?
    end

    def linkedin
      @data['linkedin_url'].split('/').last if found?
    end

    def bio
      @data['bio'] + @data['what_i_do'] if found?
    end

    def fund_types
      return [] unless found? && @data['roles'].present?
      @fund_types ||= @data['roles'].map { |r| ROLES[r['name']] }.compact
    end

    private

    def fetch!
      if @id_or_slug.is_a?(Integer)
        @data = self.class.api_get("/users/#{@id_or_slug}")
      else
        @data = self.class.api_get('/users/search', slug: @id_or_slug)
      end
    end

    def self.base_cache_key
      'http/angelist/user'
    end

    def self._api_get(path, query)
      key_cached(query.merge(path: path)) do
        Retriable.retriable { get(path, query: query).parsed_response }
      end
    end

    def self.api_get(path, query = {})
      if @timeout.present?
        Timeout::timeout(@timeout) { _api_get(path, query) }
      else
        _api_get(path, query)
      end
    rescue Timeout::Error
      []
    end
  end
end
