class InvestorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :low

  def perform(investor_id)
    investor = Investor.find(investor_id)
    investor.crunchbase_id = Http::Crunchbase::Person.find_investor_id(investor.name, investor.competitor.name)
    investor.al_id = Http::AngelList::User.find_id(investor.name, investor.competitor.name)
    investor.populate_from_cb!
    investor.populate_from_al!
    investor.crawl_homepage!
    investor.crawl_posts!
    investor.fetch_news!
    investor.set_timezone!
    investor.set_gender!
    save_and_fix_duplicates!(investor) if investor.changed?
  end

  private

  def save_and_fix_duplicates!(investor)
    begin
      investor.save!
    rescue ActiveRecord::RecordInvalid => e
      raise unless e.record.errors.details.all? { |k,v| v.all? { |e| e[:error].to_sym == :taken } }
      attrs = e.record.errors.details.transform_values { |v| v.first[:value] }
      other = Investor.where(attrs).first
      other.update! attrs.transform_values { |v| nil }
      investor.save!
      self.class.perform_later(other.id)
    end
  end
end
