module Concerns
  module Targetable
    extend ActiveSupport::Concern

    def with_founder(founder)
      @founder = founder
      self
    end

    private

    def target_investor
      if self.attributes.key?('target_investor')
        self[:target_investor]
      elsif @founder.present?
        @founder.target_investors.order(updated_at: :desc).limit(1).first.as_json(only: [:id, :stage], methods: [], include: [])
      end
    end
  end
end
