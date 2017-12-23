module CompetitorLists::Base::ClassSql
  def target_investor_sql(founder, competitors_table = 'competitors')
    <<-SQL
        LEFT JOIN LATERAL (
          SELECT target_investors.stage
          FROM investors
          INNER JOIN target_investors ON target_investors.investor_id = investors.id AND target_investors.founder_id = #{founder.id}
          WHERE investors.competitor_id = #{competitors_table}.id
          ORDER BY target_investors.updated_at DESC
          LIMIT 1
        ) AS ti ON true
    SQL
  end

  def partners_sql(competitors_table = 'competitors')
    all_results = <<-SQL
      SELECT id, role
      FROM investors
      WHERE investors.competitor_id = #{competitors_table}.id
    SQL
    ids = <<-SQL
      WITH
        partners_results AS (#{all_results}),
        filtered_partners_results AS (
          SELECT * FROM partners_results
          WHERE LOWER(partners_results.role) ILIKE ANY (ARRAY[#{Competitor::INVESTOR_TITLE.map { |t| "'%#{t}%'" }.join(', ')}])
        )
      SELECT id FROM filtered_partners_results
      UNION
      SELECT id FROM partners_results
      WHERE NOT EXISTS (SELECT * FROM filtered_partners_results)
    SQL
    partners_sql = <<-SQL
      SELECT investors.id, investors.first_name, investors.last_name
      FROM investors
      INNER JOIN (#{ids}) AS ids ON investors.id = ids.id
      LEFT OUTER JOIN investments ON investments.investor_id = investors.id
      GROUP BY investors.id
      ORDER BY
        investors.featured DESC,
        investors.verified DESC,
        MAX(investments.funded_at) DESC NULLS LAST,
        COUNT(investments.id) DESC
      LIMIT 15
    SQL
    <<-SQL
      LEFT JOIN LATERAL (
        SELECT array_agg(partners) AS partners_arr
        FROM (#{partners_sql}) AS partners
      ) AS partners ON true
    SQL
  end

  def recent_investments_sql(competitors_table = 'competitors')
    investments_sql = <<-SQL
        SELECT companies.id, companies.name, companies.domain, companies.crunchbase_id
        FROM companies
        INNER JOIN investments ON investments.company_id = companies.id
        WHERE investments.competitor_id = #{competitors_table}.id
        GROUP BY companies.id
        ORDER BY
          MAX(investments.funded_at) DESC NULLS LAST,
          COUNT(NULLIF(investments.featured, false)) DESC,
          companies.capital_raised DESC,
          COUNT(investments.id) DESC
        LIMIT 5
    SQL
    <<-SQL
        LEFT JOIN LATERAL (
          SELECT array_agg(recent_investments) AS ri_arr
          FROM (#{investments_sql}) AS recent_investments
        ) AS ri ON true
    SQL
  end

  def _meta_select(meta_sql)
    meta_sql.present? ? ', row_to_json(metaquery.*) AS meta' : ''
  end

  def _meta_join(meta_sql)
    meta_sql.present? ? "LEFT JOIN LATERAL (#{meta_sql}) metaquery ON true" : ''
  end

  def _order_clause(order)
    order.present? ? "ORDER BY #{order}" : ''
  end

  def _base_sql(founder, sql, meta_sql, order, limit, offset, include_targets: false)
    fetch_targets = cache_key_attrs.blank? && founder.present? && include_targets
    distinct_sql = <<-SQL
        SELECT DISTINCT ON (fullquery.id) fullquery.*
        FROM (#{sql}) AS fullquery
    SQL
    limited_sql = <<-SQL
        SELECT distincted.* #{fetch_targets ? ', ti.*' : ''}
        FROM (#{distinct_sql}) AS distincted
        #{target_investor_sql(founder, 'distincted') if fetch_targets}
        #{_order_clause(order)}
        OFFSET #{offset}
        LIMIT #{limit}
    SQL
    <<-SQL
        SELECT
          subquery.*,
          array_to_json(partners.partners_arr) AS partners,
          array_to_json(ri.ri_arr) AS recent_investments
          #{_meta_select(meta_sql)}
        FROM (#{limited_sql}) AS subquery
        #{recent_investments_sql('subquery')}
        #{partners_sql('subquery')}
        #{_meta_join(meta_sql)}
    SQL
  end
end