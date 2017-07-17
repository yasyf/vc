class InvestorCrunchbaseJob < ApplicationJob
  queue_as :default

  def perform(investor_id)
    investor = Investor.find(investor_id)
    investor.crunchbase_id ||= Http::Crunchbase::Person.find_investor_id(investor.name)
    investor.populate_from_cb!
    investor.save! if investor.changed?
  end
end
