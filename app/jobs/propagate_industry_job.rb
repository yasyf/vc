class PropagateIndustryJob < ApplicationJob
  FUND_TYPE_THRESHOLD = 0.5

  queue_as :low

  def perform
    PropagateIndustryUpJob.perform_later 'Investor'
    PropagateIndustryUpJob.perform_later 'Competitor'
    propagate_industry_down
    propagate_fund_type_up
  end

  private

  def propagate_fund_type_up
    #TODO: do this in sql
    Competitor.find_each do |c|
      fund_types = Hash.new(0)
      c.investors.find_each do |i|
        i.fund_type.each do |ft|
          fund_types[ft] += 1
        end if i.fund_type.present?
      end
      next unless fund_types.present?
      total = c.investors.count
      fund_type = fund_types.keys.select { |ft| fund_types[ft] > FUND_TYPE_THRESHOLD * total }
      c.fund_type = fund_type if fund_type.present?
      c.save! if c.changed?
    end
  end

  def propagate_industry_down
    query = <<-SQL
      UPDATE investors AS i
        SET industry = c.industry
          FROM competitors AS c
          WHERE i.competitor_id = c.id
            AND (i.industry = '{}' OR i.industry IS NULL)
    SQL
    Investor.connection.update(query)
  end
end
