module Concerns
  module Targetable
    extend ActiveSupport::Concern

    private

    def target_investor
      if self.attributes.key?('target_investor')
        self[:target_investor]
      else
        target_investors.order(updated_at: :desc).limit(1).first.as_json(only: [:id, :stage], methods: [], include: [])
      end
    end
  end
end
