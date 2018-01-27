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

    def crunchbase_id=(cb_id)
      parsed = cb_id&.split('/')&.last
      parsed.present? ? super(parsed) : super(cb_id)
    end

    def al_id=(al_id)
      parsed = al_id&.split('/')&.last if al_id.is_a?(String)
      parsed.present? ? super(parsed) : super(al_id)
    end

    def fix_linkedin!
      return unless self.linkedin.present?
      self.linkedin = nil if self.linkedin.include?('view')
    end
  end
end
