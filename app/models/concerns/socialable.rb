module Concerns
  module Socialable
    extend ActiveSupport::Concern

    def twitter=(twitter)
      parsed = twitter&.split('/')&.last
      twitter = parsed.present? ? parsed : twitter
      super twitter&.first == '@' ? twitter[1..-1] : twitter
    end

    def linkedin=(linkedin)
      unless linkedin.present?
        super linkedin
        return
      end
      parsed = linkedin.split('/').drop(4).join('/')
      parsed.present? ? super(parsed) : super(linkedin)
    end

    def fix_linkedin!
      return unless self.linkedin.present?
      self.linkedin = nil if self.linkedin.include?('view')
    end
  end
end
