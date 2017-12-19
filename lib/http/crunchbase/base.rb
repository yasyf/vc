require 'redcarpet'
require 'redcarpet/render_strip'

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
      response.permalink
    end

    def crunchbase_url
      path = response.web_path
      "https://www.crunchbase.com/#{path}" if path.present?
    end

    def url
      response.homepage_url
    end

    def image
      response.profile_image_url
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
      site.url if site.present? && !site.url.include?('google.com')
    end

    def news
      response.news&.map { |n| n.properties.slice('url', 'posted_on') } || []
    end

    def self.find_id(query)
      result = api_get('/', query).first
      result&.permalink
    end

    def found?
      response.present?
    rescue Errors::APIError
      @raise_on_error ? raise : false
    end

    private

    def extract_website_id(name, index)
      site = website_of_type(name)
      url = site&.url&.split('/')
      return nil unless url.present? && url.length > [3, index].max
      url[index].downcase.split(/[?#]/).first
    end

    def website_of_type(type)
      websites.find { |site| site.website_type == type }
    end

    def websites
      response.websites || []
    end

    def self.api_get(path, query = {}, multi = true)
      data = key_cached(query.merge(path: path)) do
        Retriable.retriable(on: Errors::APIError) { _api_get(path, query) }
      end
      if multi
        return [] unless data.present? && data['items'].present?
        data['items'].map { |resp| ApiObject.new(resp) }
      else
        return nil unless data.present?
        ApiObject.new(data)
      end
    end

    def self._api_get(raw_path, query)
      path = Addressable::URI.parse(raw_path).normalized_path
      response = get(path, query: query.merge(user_key: next_token), open_timeout: @timeout, read_timeout: @timeout)
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
    rescue Timeout::Error
      raise Errors::Timeout.new(raw_path)
    end

    def self.base_cache_key
      'http/crunchbase'
    end

    def self.next_token
      ENV['CB_API_KEY'].split(',').sample
    end

    def self.markdown
      @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    end

    def response
      @response ||= search_for_data || ApiObject.new({})
    end

    def search_for_data
      raise 'must implement search_for_data'
    end
  end
end
