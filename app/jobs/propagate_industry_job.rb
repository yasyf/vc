class PropagateIndustryJob < ApplicationJob
  COMPETITOR_INDUSTRIES = 3

  queue_as :low

  def perform
    propagate_down
    propagate_up
  end

  private

  def propagate_down
    query = <<-SQL
      UPDATE investors AS i
        SET industry = c.industry
          FROM competitors AS c
          WHERE i.competitor_id = c.id
            AND (i.industry = '{}' OR i.industry IS NULL)
    SQL
    Investor.connection.update(query)
  end

  def propagate_up
    #TODO: do this in sql
    query = <<-SQL
      SELECT competitors.id, array_agg(c_t.ind_t) as industries
      FROM 
       (
        SELECT id, industry, unnest(industry) as ind_t
        FROM companies
      ) c_t 
      INNER JOIN companies_competitors ON c_t.id = companies_competitors.company_id
      INNER JOIN competitors ON competitors.id = companies_competitors.competitor_id
      WHERE (c_t.industry <> '{}' AND c_t.industry IS NOT NULL)
      GROUP BY competitors.id
    SQL
    Competitor.transaction do
      Competitor.connection.execute(query).to_a.each do |result|
        industries = result['industries'][1...-1].split(',')
        frequencies = industries.each_with_object(Hash.new(0)) do |i, h|
          h[i] += 1
        end
        top = industries.sort { |i| frequencies[i] }.first(COMPETITOR_INDUSTRIES)
        Competitor.update(result['id'], industry: top)
      end
    end
  end
end
