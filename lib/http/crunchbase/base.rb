module Http::Crunchbase
  class Base
    extend Concerns::Cacheable

    include HTTParty
    base_uri 'https://api.crunchbase.com/v/3/'
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
      "https://www.crunchbase.com/#{path}"
    end

    def twitter
      extract_website_id 'twitter', -1
    end

    def linkedin
      extract_website_id 'linkedin', 4
    end

    def facebook
      extract_website_id 'facebook', -1
    end

    def homepage
      site = websites&.find { |site| site['properties']['website_type'] == 'homepage' }
      site['properties']['url'] if site.present?
    end

    def self.find_id(query)
      result = api_get('/', query).first
      result && result['properties']['permalink']
    end

    private

    def extract_website_id(name, index)
      site = websites&.find { |site| site['properties']['website_type'] == name }
      return nil unless site.present?
      url = site['properties']['url']&.split('/')
      return nil unless url.present? && url.length > 3
      url[index].downcase.split(/[?#]/).first
    end

    def websites
      get_in 'relationships', 'websites', multi: true
    end

    def self.api_get(raw_path, query = {}, multi = true)
      path = URI.encode raw_path
      data = key_cached(query.merge(path: path)) do
        response = get(path, query: query)
        case response.code
          when 200
            response.parsed_response['data']
          when 404
            nil
          when 401
            Rails.logger.warn "Crunchbase 401: #{path}/#{query}"
            nil
          else
            raise "Crunchbase #{response.code}: #{path}/#{query}"
        end
      end
      multi ? (data && data['items']) || [] : data
    end

    def self.base_cache_key
      "http/crunchbase"
    end

    def get_in_raw(path, multi)
      return nil unless found?
      current = search_for_data
      while path.present?
        current = current[path.shift]
        return nil if current.nil?
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

    def found?
      search_for_data.present?
    end

    def search_for_data
      raise "must implement search_for_data"
    end
  end
end
