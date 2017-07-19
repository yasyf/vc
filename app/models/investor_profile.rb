class InvestorProfile < ApplicationRecord
  include Concerns::AttributeSortable

  belongs_to :founder

  enum funding_size: Competitor::FUNDING_SIZES.keys
  sort :industry

  def complete?
    industry.present? && !funding_size.nil? && city.present?
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:industry, :city, :funding_size], methods: [:complete?])
  end
end
