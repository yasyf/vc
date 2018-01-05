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
    save_and_fix_duplicates!(investor) if investor.changed?
    %i(homepage facebook twitter).each do |attr|
      save_without!(investor, attr)
      break unless investor.changed?
      save_and_fix_duplicates!(investor)
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

  def save_and_fix_duplicates!(investor)
    begin
      investor.save!
    rescue ActiveRecord::RecordInvalid => e
      raise unless e.record.errors.details.all? { |k,v| v.all? { |e| e[:error].to_sym == :taken } }
      attrs = e.record.errors.details.transform_values { |v| v.first[:value] }
      other = Investor.where(attrs).first
      return unless other.present?
      begin
        other.destroy!
        Investor.from_crunchbase(other.crunchbase_id) if other.crunchbase_id.present? && other.crunchbase_id != investor.crunchbase_id
      rescue ActiveRecord::InvalidForeignKey
        other.update! attrs.transform_values { |v| nil }.merge(email: nil, al_id: nil)
        self.class.perform_later(other.id)
      end
      ignore_invalid { investor.save! }
    end
  end
end
