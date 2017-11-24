class CompanyCleanJob < ApplicationJob
  include Concerns::Ignorable

  queue_as :default

  def perform
    fix_domain_cb_split!
    fix_incorrect_al_id!
  end

  private

  def fix_domain_cb_split!
    in_batches(Company.where.not(crunchbase_id: nil).where(domain: nil)) do |company|
      next unless (url = company.crunchbase_org.url).present?
      domain = Util.parse_domain(url)
      begin
        Company.where(domain: domain).destroy_all
      rescue ActiveRecord::ActiveRecordError
        Company.where(domain: domain).update_all domain: nil
      end
      company.update! domain: domain
    end
  end

  def fix_incorrect_al_id!
    in_batches(Company.where.not(crunchbase_id: nil).where(al_id: nil)) do |company|
      al_id = Http::AngelList::Startup.find_id(company.name)
      next unless al_id.present?
      al_startup = Http::AngelList::Startup.new(al_id)
      next unless al_startup.crunchbase == company.crunchbase_id
      begin
        Company.where(al_id: al_id).destroy_all
      rescue ActiveRecord::ActiveRecordError
        Company.where(al_id: al_id).update_all al_id: nil
      end
      company.update! al_id: al_id
    end
  end

  def in_batches(scope)
    scope.find_in_batches do |items|
      Parallel.each(items, in_threads: 32) do |item|
        ActiveRecord::Base.connection_pool.with_connection do
          Rails.logger.info "FIXING: #{item}"
          begin
            yield item
          rescue Exception => e
            Rails.logger.info "ERROR: #{e}"
          end
        end
      end
    end
  end
end
