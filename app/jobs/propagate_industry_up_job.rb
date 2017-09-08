class PropagateIndustryUpJob < ApplicationJob
  NUM_INDUSTRIES = 3

  queue_as :low

  def perform(name)
    propagate_industry_up_to(name.constantize)
  end

  private

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