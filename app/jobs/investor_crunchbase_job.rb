class InvestorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :long

  def perform(investor_id)
    investor = Investor.find(investor_id)
    investor.crunchbase_id ||= Http::Crunchbase::Person.find_investor_id(investor.name)
    investor.al_id ||= Http::AngelList::User.find_id(investor.name)
    investor.populate_from_cb!
    investor.populate_from_al!
    investor.crawl_homepage!
    investor.crawl_posts!
    investor.fetch_news!
    investor.set_timezone!
    investor.set_gender!
    ignore_invalid { investor.save! } if investor.changed?
  end
end
