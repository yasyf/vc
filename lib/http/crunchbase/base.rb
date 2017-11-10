module Http::Crunchbase
  class Base
    extend Concerns::Cacheable

    include HTTParty
    base_uri 'https://api.crunchbase.com/v3.1/'
    format :json
    headers 'Content-Type': 'application/json'

    def initialize(timeout = nil, raise_on_error = true)
      @timeout = timeout
      @raise_on_error = raise_on_error
    end

    def permalink
      get_in 'properties', 'permalink'
    end

    def crunchbase_url
      path = get_in 'properties', 'web_path'
      "https://www.crunchbase.com/#{path}" if path.present?
    end

    def url
      get_in 'properties', 'homepage_url'
    end

    def image
      get_in 'properties', 'profile_image_url'
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
      news.select(&:present?).map { |n| n['properties'].slice('url', 'posted_on') }
    end

    def self.find_id(query)
      result = api_get('/', query).first
      result && result['properties']['permalink']
    end

    def found?
      search_for_data.present?
    rescue Errors::APIError
      @raise_on_error ? raise : false
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
      websites&.find { |site| site['properties'].present? && site['properties']['website_type'] == type }
    end

    def websites
      get_in 'relationships', 'websites', multi: true
    end

    def self.api_get(raw_path, query = {}, multi = true)
      path = URI.encode raw_path
      data = key_cached(query.merge(path: path)) do
        Retriable.retriable(on: Errors::APIError) { _api_get(path, query) }
      end
      multi ? (data && data['items']) || [] : data
    end

    def self._api_get(path, query)
      response = get(path, query: query.merge(user_key: next_token))
      case response.code
        when 200
          response.parsed_response['data']
        when 404
          nil
        when 401
          raise Errors::RateLimited.new(response.code)
        when 400
          raise Errors::BadRequest.new(response.body)
        else
          raise Errors::APIError.new("#{response.code}: #{response.body}")
      end
    end

    def self.base_cache_key
      'http/crunchbase'
    end

    def self.next_token
      ENV['CB_API_KEY'].split(',').sample
    end

    def get_in_raw(path, multi)
      return (multi ? [] : nil) unless found?
      current = search_for_data
      while path.present?
        current = current[path.shift]
        return (multi ? [] : nil) if current.nil?
      end
      multi ? (current['items'] || []) : current
    end

    def get_in(*path, multi: false)
      if @timeout.present?
        Timeout::timeout(@timeout) { get_in_raw(path, multi) }
      else
        get_in_raw(path, multi)
      end
    rescue Timeout::Error
      raise Errors::Timeout.new(path)
    end

    def search_for_data
      raise 'must implement search_for_data'
    end
  end
end
