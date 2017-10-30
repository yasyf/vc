module Concerns
  module Domainable
    extend ActiveSupport::Concern

    def website
      "http://#{domain}" if domain.present?
    end

    def domain=(domain)
      super Util.parse_domain(domain)
    end
  end
end
