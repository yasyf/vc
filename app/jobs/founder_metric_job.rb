class FounderMetricJob < ApplicationJob
  queue_as :low

  def perform(founder_id)
    founder = Founder.find(founder_id)
    company = founder.primary_company
    return unless company.present?
    cb_id = company.crunchbase_org.founders.find { |f| f.first_name == founder.first_name && f.last_name == founder.last_name }&.permalink
    return unless cb_id.present?
    founder.cb_id = cb_id
    founder.send(:set_metrics!)
    founder.save!
  end
end
