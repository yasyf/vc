module Concerns
  module Cacheable
    extend ActiveSupport::Concern

    private

    def cached(options = {}, &block)
      cache_fetch base_cache_key, options, &block
    end

    def key_cached(key_hash, options = {}, &block)
      key = "#{base_cache_key}/#{key_hash.sort.to_param.gsub('/', '%2F')}"
      cache_fetch key, options, &block
    end

    def cache_fetch(key, options, &block)
      Rails.cache.fetch(key, options.reverse_merge(cache_options), &block)
    end

    def cache_options
      { expires_in: jitter(1, :week) }
    end

    def jitter(value, period)
      value.send(period) + (rand * value).send(period)
    end

    def base_cache_key
      "#{cache_key}/#{caller_locations(2,1).first.label}"
    end
  end
end
