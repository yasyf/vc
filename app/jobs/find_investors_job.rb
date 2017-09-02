class FindInvestorsJob < ApplicationJob
  include Concerns::CacheIgnorable
  queue_as :low

  MIN_TARGET_COUNT = 3
  MIN_RATIO = 0.5

  PROPAGATE_FIELDS = %w(role email)
  PROPAGATE_ARRAY_FIELDS = %w(industry fund_type)
  ALL_PROP_FIELDS = PROPAGATE_FIELDS + PROPAGATE_ARRAY_FIELDS

  def perform
    fill_missing!
    propagate_fields!

  end

  private

  def fill_missing!
    missing = TargetInvestor.investor_fields_filled.where(investor_id: nil)
    missing.find_each do |ti|
      next if ignored?(ti.id)
      ignore! ti.id
      ti.find_investor!
    end

    missing
      .group(*TargetInvestor::INVESTOR_FIELDS)
      .having('count(*) > 2')
      .pluck('array_agg(id)', *TargetInvestor::INVESTOR_FIELDS)
      .map { |x| TargetInvestor::INVESTOR_FIELDS.unshift(:ids).zip(x).to_h.with_indifferent_access }
      .each do |ti|
        competitor = Competitor.create_from_name!(ti[:firm_name])
        investor = Investor.where(ti.slice(:first_name, :last_name).merge(competitor: competitor)).first_or_create!
        ids = TargetInvestor.where(id: ti[:ids]).select('DISTINCT ON (founder_id) id')
        TargetInvestor.where(id: ids).update_all(investor_id: investor.id)
    end
  end

  def propagate_fields!
    scope = ALL_PROP_FIELDS.inject(Investor.none) { |scope, f| scope.or(Investor.where(f => nil)) }
    scope = Investor.where('target_investors_count >= ?', MIN_TARGET_COUNT).merge(scope)
    scope.includes(:target_investors).find_each do |investor|
      fields = ALL_PROP_FIELDS.map { |f| [f, Hash.new(0)] }.to_h
      investor.target_investors.each do |ti|
        PROPAGATE_FIELDS.each do |f|
          fields[f][ti[f]] += 1 if ti[f].present?
        end
        PROPAGATE_ARRAY_FIELDS.each do |f|
          ti[f].each do |x|
            fields[f][x] += 1
          end if ti[f].present?
        end
      end
      PROPAGATE_FIELDS.each do |f|
        max = fields[f].max_by(&:last)
        next unless max.present?
        if max.last > MIN_RATIO * investor.target_investors.where.not(f => nil).count
          investor[f] = max.first
        end
      end
      PROPAGATE_ARRAY_FIELDS.each do |f|
        maxes = fields[f].keys.select do |k|
          fields[f][k] > MIN_RATIO * investor.target_investors.where.not(f => nil).count
        end
        investor[f] = maxes if maxes.present?
      end
      investor.save! if investor.changed?
    end
  end
end
