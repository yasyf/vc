class InvestorCrunchbaseJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :long

  def perform(investor_id)
    investor = Investor.find(investor_id)
    unless investor.verified?
      investor.crunchbase_id = Http::Crunchbase::Person.find_investor_id(investor.name, investor.competitor.name)
      investor.al_id = Http::AngelList::User.find_id(investor.name, org: investor.competitor.name)
      investor.populate_from_cb!
      investor.populate_from_al!
    end
    investor.save_and_fix_duplicates! if investor.changed?
    %i(homepage facebook twitter).each do |attr|
      save_without!(investor, attr)
      break unless investor.changed?
      investor.save_and_fix_duplicates!
      break unless investor.changed?
    end if investor.changed?
    investor.crawl_homepage!
    investor.crawl_posts!
    investor.fetch_news!
    investor.set_timezone!
    investor.set_gender!
    investor.set_average_response_time!
    ignore_invalid { investor.save! } if investor.changed?
  end

  private

  def save_without!(investor, field)
    begin
      investor.save!
    rescue ActiveRecord::RecordInvalid
      if investor.errors.details.keys.include?(field)
        investor.public_send("#{field}=", investor.public_send("#{field}_was"))
        ignore_invalid { investor.save! }
      end
    end
  end
end
