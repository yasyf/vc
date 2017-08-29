class FindInvestorsJob < ApplicationJob
  include Concerns::CacheIgnorable
  queue_as :low

  def perform
    missing = TargetInvestor.investor_fields_filled.where(investor_id: nil)
    missing.find_each do |ti|
      next if ignored?(ti.id)
      ignore! ti.id
      ti.find_investor!
    end

    missing
      .group(*TargetInvestor::INVESTOR_FIELDS)
      .having('count(*) > 1')
      .pluck('array_agg(id)', *TargetInvestor::INVESTOR_FIELDS)
      .map { |x| TargetInvestor::INVESTOR_FIELDS.unshift(:ids).zip(x).to_h.with_indifferent_access }
      .each do |ti|
        competitor = Competitor.create_from_name!(ti[:firm_name])
        investor = Investor.where(ti.slice(:first_name, :last_name).merge(competitor: competitor)).first_or_create!
        ids = TargetInvestor.where(id: ti[:ids]).select('DISTINCT ON (founder_id) id')
        TargetInvestor.where(id: ids).update_all(investor_id: investor.id)
    end
  end
end
