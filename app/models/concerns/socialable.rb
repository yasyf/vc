module Concerns
  module Socialable
    extend ActiveSupport::Concern

    def linkedin=(linkedin)
      super (linkedin && (linkedin.split('/')[4] || linkedin.split('/').last)) || linkedin
    end
  end
end
