module Http::Crunchbase
  class Base
    extend Concerns::Cacheable

    include HTTParty
    base_uri 'https://api.crunchbase.com/v3.1/'
    format :json
    headers 'Content-Type': 'application/json'
    default_params user_key: ENV['CB_API_KEY']

    def initialize(timeout = nil)
      @timeout = timeout
    end

    def permalink
      get_in 'properties', 'permalink'
    end

    def crunchbase_url
      path = get_in 'properties', 'web_path'
      "https://www.crunchbase.com/#{path}" if path.present?
    end

    def twitter
      extract_website_id 'twitter', -1
    end

    def linkedin
      username = extract_website_id 'linkedin', 4
      username unless username.in?(%w(view))
    end

    def facebook
      extract_website_id 'facebook', -1
    end

    def homepage
      site = website_of_type('homepage')
      site['properties']['url'] if site.present? && !site.include?('google.com')
    end

    def news
      news = get_in 'relationships', 'news', multi: true
      news.map { |n| n['properties'].slice('url', 'title') }
    end

    def self.find_id(query)
      result = api_get('/', query).first
      result && result['properties']['permalink']
    end

    def found?
      search_for_data.present?
    rescue Errors::APIError
      false
    end

    private

    def extract_website_id(name, index)
      site = website_of_type(name)
      return nil unless site.present?
      url = site['properties']['url']&.split('/')
      return nil unless url.present? && url.length > [3, index].max
      url[index].downcase.split(/[?#]/).first
    end

    def website_of_type(type)
      websites&.find { |site| site['properties']['website_type'] == type }
    end

    def websites
      get_in 'relationships', 'websites', multi: true
    end

    def self.api_get(raw_path, query = {}, multi = true)
      path = URI.encode raw_path
      data = key_cached(query.merge(path: path)) do
        Retriable.retriable { _api_get(path, query) }
      end
      multi ? (data && data['items']) || [] : data
    end

    def self._api_get(path, query)
      response = get(path, query: query)
      case response.code
        when 200
          response.parsed_response['data']
        when 404
          nil
        when 401
          raise Errors::RateLimited.new(response.code)
        else
          raise Errors::APIError.new(response.code)
      end
    end

    def self.base_cache_key
      'http/crunchbase'
    end

    def get_in_raw(path, multi)
      return (multi ? [] : nil) unless found?
      current = search_for_data
      while path.present?
        current = current[path.shift]
        return (multi ? [] : nil) if current.nil?
      end
      multi ? current['items'] : current
    end

    def get_in(*path, multi: false)
      if @timeout.present?
        Timeout::timeout(@timeout) { get_in_raw(path, multi) }
      else
        get_in_raw(path, multi)
      end
    rescue Timeout::Error, JSON::ParserError # when we hit rate limiting
      multi ? [] : nil
    end

    def search_for_data
      raise "must implement search_for_data"
    end
  end
end
