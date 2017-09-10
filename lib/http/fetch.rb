class Http::Fetch
  CACHE_DIR = "#{Rails.root}/tmp/http_cache"
  EASY_OPTIONS = { follow_location: true }
  MULTI_OPTIONS = { pipeline: Curl::CURLPIPE_MULTIPLEX | Curl::CURLPIPE_HTTP1 }
  OK = '200 OK'

  def self.cache
    @cache ||= ActiveSupport::Cache.lookup_store(:file_store, CACHE_DIR)
  end

  def self.get_one(url)
    get([url]).values.first
  end

  def self.get(urls)
    results = cache.read_multi(*urls)
    remaining = urls - results.keys
    Curl::Multi.get(remaining, EASY_OPTIONS, MULTI_OPTIONS) do |resp|
      if resp.status == OK
        results[resp.url] = resp.body_str
        cache.write(resp.url, resp.body_str)
      else
        results[resp.url] = nil
      end
    end if remaining.present?
    results
  end
end
