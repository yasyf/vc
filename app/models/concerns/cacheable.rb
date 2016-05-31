module Concerns
  module Cacheable
    extend ActiveSupport::Concern

    private

    def cached(options = {}, &block)
      cache_fetch base_cache_key, options, &block
    end

    def key_cached(key_hash, options = {}, &block)
      cache_fetch "#{base_cache_key}/#{key_hash.sort.to_param}", options, &block
    end

    def cache_fetch(key, options, &block)
      Rails.cache.fetch(key, options.reverse_merge(base_options), &block)
    end

    def base_options
      { expires_in: 1.week + (rand * 7).days }
    end

    def base_cache_key
      "#{cache_key}/#{caller_locations(2,1).first.label}"
    end
  end
end
