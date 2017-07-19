class CacheWarmJob < ActiveJob::Base
  queue_as :default

  def perform
    Company.includes(:team, :users, :competitors).find_each do |company|
      company.send(:crunchbase_org, 5)
      %w(stats).each do |method|
        company.pitch&.public_send(method)
      end
      %w(funded? partner_names as_json).each do |method|
        company.public_send(method)
      end
    end
    Team.for_each do |team|
      %w(portfolio_follow_on anti_portfolio_follow_on).each do |method|
        team.public_send(method)
      end
    end
  end
end
