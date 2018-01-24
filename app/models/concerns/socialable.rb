module Concerns
  module Socialable
    extend ActiveSupport::Concern

    def twitter=(twitter)
      twitter = twitter&.split('/')&.last || twitter
      super twitter&.first == '@' ? twitter[1..-1] : twitter
    end

    def linkedin=(linkedin)
      super (linkedin && linkedin.split('/').drop(4).join('/')) || linkedin
    end

    def fix_linkedin!
      return unless self.linkedin.present?
      self.linkedin = nil if self.linkedin.include?('view')
    end
  end
end
