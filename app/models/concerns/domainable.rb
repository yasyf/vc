module Concerns
  module Domainable
    extend ActiveSupport::Concern

    def website
      "http://#{domain}" if domain.present?
    end

    def domain=(domain)
      parsed = begin
        URI.parse(domain).host
      rescue URI::InvalidURIError => _
      end || domain

      parsed = parsed[4..-1] if parsed&.starts_with?('www.')
      super parsed
    end
  end
end
