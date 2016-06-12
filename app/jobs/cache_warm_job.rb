class CacheWarmJob < ActiveJob::Base
  queue_as :default

  def perform
    Company.all.each do |company|
      %w(quorum? funded? stats partner_initials).each do |method|
        company.public_send(method)
      end
    end
  end
end
