class PropagateIndustryJob < ApplicationJob
  NUM_INDUSTRIES = 3
  FUND_TYPE_THRESHOLD = 0.5

  queue_as :low

  def perform
    propagate_industry_up_to(Investor)
    propagate_industry_up_to(Competitor)
    propagate_industry_down
    propagate_fund_type_up
  end

  private

  def propagate_fund_type_up
    #TODO: do this in sql
    Competitor.includes(:investors).find_each do |c|
      fund_types = Hash.new(0)
      c.investors.each do |i|
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


  def propagate_industry_up_to(klass)
    #TODO: do this in sql
    name = klass.name.downcase
    table = "#{name}s"

    query = <<-SQL
      SELECT #{table}.id, array_agg(c_t.ind_t) as industries
      FROM 
       (
        SELECT id, industry, unnest(industry) as ind_t
        FROM companies
      ) c_t 
      INNER JOIN companies_competitors ON c_t.id = companies_competitors.company_id
      INNER JOIN #{table} ON #{table}.id = companies_competitors.#{name}_id
      WHERE (c_t.industry <> '{}' AND c_t.industry IS NOT NULL)
      GROUP BY #{table}.id
    SQL
    Competitor.transaction do
      Competitor.connection.execute(query).to_a.each do |result|
        industries = result['industries'][1...-1].split(',')
        frequencies = industries.each_with_object(Hash.new(0)) do |i, h|
          h[i] += 1
        end
        top = industries.sort { |i| frequencies[i] }.first(NUM_INDUSTRIES)
        klass.update(result['id'], industry: top)
      end
    end
  end
end
