class CacheWarmJob < ActiveJob::Base
  queue_as :low

  def perform
    Company.find_each do |company|
      warm_company company
    end
    Team.for_each do |team|
      warm_team team
    end
  end

  private

  def warm_company(company)
    company.send(:crunchbase_org, 5)
    %w(stats).each do |method|
      company.pitch&.public_send(method)
    end
    %w(funded? partner_names as_json).each do |method|
      company.public_send(method)
    end
  rescue
    nil
  end

  def warm_team(team)
    %w(portfolio_follow_on anti_portfolio_follow_on).each do |method|
      team.public_send(method)
    end
  rescue
    nil
  end
end
