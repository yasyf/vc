module Concerns
  module CacheIgnorable
    extend ActiveSupport::Concern

    private

    def ignored_prefix
      "#{self.class.name.underscore}/cache_ignored"
    end

    def ignored?(id)
      Rails.cache.exist?("#{ignored_prefix}/#{id}")
    end

    def ignore!(id, length: 1.month)
      Rails.cache.write("#{ignored_prefix}/#{id}", true, expires_in: length)
    end
  end
end
