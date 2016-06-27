class CacheWarmJob < ActiveJob::Base
  queue_as :default

  def perform
    Company.all.each do |company|
      begin
        %w(quorum? funded? stats partner_initials).each do |method|
          company.public_send(method)
        end
      rescue Trello::Error => e
        company.destroy! if e.message =~ /not found/
      end
    end
  end
end
