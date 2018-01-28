module CompetitorLists::Base::ClassSql
  def target_investor_sql(founder, competitors_table = 'competitors')
    <<-SQL
      LEFT JOIN LATERAL (
        SELECT target_investors.stage
        FROM investors
        INNER JOIN target_investors ON target_investors.investor_id = investors.id AND target_investors.founder_id = #{founder.id}
        WHERE investors.competitor_id = #{competitors_table}.id AND target_investors.stage != #{TargetInvestor::RAW_STAGES.keys.index(:deleted)}
        ORDER BY target_investors.updated_at DESC
        LIMIT 1
      ) AS ti ON true
    SQL
  end

  def partners_sql(competitors_table = 'competitors')
    <<-SQL
      INNER JOIN competitor_partners ON competitor_partners.competitor_id = #{competitors_table}.id
    SQL
  end

  def recent_investments_sql(competitors_table = 'competitors')
    <<-SQL
      INNER JOIN competitor_recent_investments ON competitor_recent_investments.competitor_id = #{competitors_table}.id
    SQL
  end

  def velocity_sql(competitors_table = 'competitors')
    <<-SQL
      LEFT OUTER JOIN competitor_velocities ON competitor_velocities.competitor_id = #{competitors_table}.id
    SQL
  end

  def coinvestors_sql(competitors_table = 'competitors')
    <<-SQL
      INNER JOIN competitor_coinvestors ON competitor_coinvestors.competitor_id = #{competitors_table}.id
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
        SELECT distincted.*, competitor_velocities.velocity #{fetch_targets ? ', ti.*' : ''}
        FROM (#{distinct_sql}) AS distincted
        #{target_investor_sql(founder, 'distincted') if fetch_targets}
        #{velocity_sql('distincted')}
        #{_order_clause(order)}
        OFFSET #{offset}
        LIMIT #{limit}
    SQL
    <<-SQL
        SELECT
          subquery.*,
          competitor_partners.partners AS partners,
          competitor_recent_investments.recent_investments AS recent_investments,
          competitor_coinvestors.coinvestors AS coinvestors
          #{_meta_select(meta_sql)}
        FROM (#{limited_sql}) AS subquery
        #{recent_investments_sql('subquery')}
        #{coinvestors_sql('subquery')}
        #{partners_sql('subquery')}
        #{_meta_join(meta_sql)}
    SQL
  end
end