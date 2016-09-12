class CacheWarmJob < ActiveJob::Base
  queue_as :default

  def perform
    Company.all.each do |company|
      company.send(:crunchbase_org, 5)
      begin
        %w(quorum? funded? stats partner_names as_json).each do |method|
          company.public_send(method)
        end
      rescue Trello::Error => e
        company.destroy! if e.message =~ /not found/
      end
    end
  end
end
