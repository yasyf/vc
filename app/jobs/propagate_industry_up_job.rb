class PropagateIndustryUpJob < ApplicationJob
  INDUSTRY_THRESHOLD = 0.05
  MAX_INDUSTRIES = 15
  INDUSTRY_DEPENDENCIES = {
    ecommerce: :consumer,
    cleantech: :energy,
    gaming: :consumer,
    government: :enterprise,
    security: :enterprise,
    saas: :enterprise,
  }

  queue_as :low

  def perform(name)
    propagate_industry_up_to(name.constantize)
    propagate_industry_down if name == 'Competitor'
  end

  private

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

  def propagate_industry_up_to(klass, limit: 1000)
    buckets = (klass.count / limit) + 1
    (0...buckets).each do |i|
      propagate_industry_up_to_with_offset klass, limit, offset
    end
  end

  def propagate_industry_up_to_with_offset(klass, limit, offset)
    #TODO: do this in sql
    name = klass.name.downcase
    table = "#{name}s"

    query = <<-SQL
      SELECT #{table}.id, array_agg(c_t.ind_t) as industries, COUNT(c_t.id) as c_count
      FROM
       (
        SELECT id, industry, unnest(industry) as ind_t
        FROM companies
      ) c_t
      INNER JOIN investments ON c_t.id = investments.company_id
      INNER JOIN #{table} ON #{table}.id = investments.#{name}_id
      WHERE (c_t.industry <> '{}' AND c_t.industry IS NOT NULL AND #{table}.verified = FALSE)
      GROUP BY #{table}.id
      LIMIT #{limit}
      OFFSET #{offset}
    SQL
    klass.connection.execute(query).to_a.each do |result|
      industries = result['industries'][1...-1].split(',')
      frequencies = industries.each_with_object(Hash.new(0)) do |i, h|
        h[i] += 1
      end
      top = frequencies
        .keys
        .select { |i| frequencies[i] > INDUSTRY_THRESHOLD * result['c_count'] }
        .sort { |i| frequencies[i] }.first(MAX_INDUSTRIES)
      INDUSTRY_DEPENDENCIES.each do |k, v|
        if top.include?(k.to_s) && !top.include?(v.to_s)
          top << v.to_s
        end
      end
      klass.update(result['id'], industry: top)
    end
  end
end
