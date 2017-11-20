module Concerns
  module Targetable
    extend ActiveSupport::Concern

    def with_founder(founder)
      @founder = founder
      self
    end

    def with_target_investor(target_investor)
      @target_investor = target_investor
      self
    end

    private

    def track_status
      if self.attributes.key?('track_status')
        TargetInvestor::STAGES.keys[self[:track_status]] if self[:track_status].present?
      elsif target_investor.present?
        target_investor['stage']
      end
    end

    def track_id
      if self.attributes.key?('track_id')
        self[:track_id]
      elsif target_investor.present?
        target_investor['id']
      end
    end

    def target_investor
      if @target_investor
        @target_investor.as_json(only: [:id, :stage], methods: [], include: [])
      elsif self.attributes.key?('target_investor')
        self[:target_investor]
      elsif @founder.present?
        @founder
          .target_investors
          .where("#{self.class.name.downcase}_id": self.id)
          .order(updated_at: :desc)
          .limit(1)
          .first
          .as_json(only: [:id, :stage], methods: [], include: [])
      end
    end
  end
end
