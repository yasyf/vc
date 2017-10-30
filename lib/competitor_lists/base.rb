module CompetitorLists
  module ClassSetup
    def inherited(klass)
      @lists << klass
    end

    def init
      @lists = []
      Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file|
        next if file == __FILE__
        require_dependency file
      end
    end

    def self.extended(base)
      base.init
    end

    def lists
      @lists
    end
  end

  module ClassSql
    def target_investor_sql(founder, competitors_table = 'competitors')
      <<-SQL
        LEFT JOIN LATERAL (
          SELECT target_investors.stage, target_investors.id
          FROM investors
          INNER JOIN target_investors ON target_investors.investor_id = investors.id AND target_investors.founder_id = #{founder.id}
          WHERE investors.competitor_id = #{competitors_table}.id
          ORDER BY target_investors.updated_at DESC
          LIMIT 1
        ) AS ti ON true
      SQL
    end

    def partners_sql(competitors_table = 'competitors')
      partners_sql = <<-SQL
        SELECT investors.id, investors.first_name, investors.last_name
        FROM investors
        LEFT OUTER JOIN investments ON investments.investor_id = investors.id
        WHERE investors.competitor_id = #{competitors_table}.id
        GROUP BY investors.id
        ORDER BY
          CASE
            WHEN investors.role IN (#{CompetitorCrunchbaseJob::INVESTOR_TITLE.map { |t| "'#{t}'" }.join(', ')}) THEN 1
            ELSE 0
          END DESC,
          MAX(investments.funded_at) DESC NULLS LAST,
          COUNT(investments.id) DESC,
          investors.featured DESC
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

    def _base_sql(founder, sql, meta_sql, order, limit, offset)
      distinct_sql = <<-SQL
        SELECT DISTINCT ON (fullquery.id) fullquery.*
        FROM (#{sql}) AS fullquery
      SQL
      limited_sql = <<-SQL
        SELECT distincted.*
        FROM (#{distinct_sql}) AS distincted
        #{_order_clause(order)}
        OFFSET #{offset}
        LIMIT #{limit}
      SQL
      fetch_target_investors = cache_key_attrs.blank? && @founder.present?
      <<-SQL
        SELECT
          subquery.*,
          #{fetch_target_investors ? 'row_to_json(ti)' : 'NULL'} AS target_investor,
          array_to_json(partners.partners_arr) AS partners,
          array_to_json(ri.ri_arr) AS recent_investments
          #{_meta_select(meta_sql)}
        FROM (#{limited_sql}) AS subquery
        #{target_investor_sql(founder, 'subquery') if fetch_target_investors}
        #{recent_investments_sql('subquery')}
        #{partners_sql('subquery')}
        #{_meta_join(meta_sql)}
      SQL
    end
  end

  module ClassBulk
    def get_if_eligible(founder, request, name)
      @lists.find { |l| l.to_param == name.to_sym && l.eligible?(founder, request) }
    end

    def get_eligibles(founder, request)
      @lists.select { |l| l.eligible? founder, request }
    end

    def _eligible?(attrs)
      true
    end

    def eligible?(founder, request)
      _eligible?(cache_values(founder, request))
    end

    def cache_key_attrs
      nil
    end

    def cache_key_fallbacks
      {}
    end

    def cache_values(founder, request)
      return {} unless cache_key_attrs.is_a?(Array)
      cache_key_attrs.map do |a|
        result = founder.present? ? founder.send(a).to_s : nil
        if result.blank? && request.present? && cache_key_fallbacks[a].present?
          result = cache_key_fallbacks[a].call(request)
        end
        [a, result]
      end.to_h
    end

    def cache_key(founder, request, name)
      return nil unless cache_key_attrs.present?
      keys = ['competitor_lists', to_param, name]
      keys += cache_values(founder, request).sort.map(&:last)
      keys.join('/')
    end

    def title
      self::TITLE
    end

    def to_param
      self.name.demodulize.underscore.to_sym
    end
  end

  module Results
    GET_LIMIT = 5

    def cache_values
      self.class.cache_values(@founder, @request)
    end

    def cache_key(name)
      self.class.cache_key(@founder, @request, name)
    end

    def cached?
      self.class.cache_key_attrs.present?
    end

    def count_sql
      <<-SQL
        SELECT COUNT(DISTINCT subquery.id)
        FROM (#{sql}) AS subquery
      SQL
    end

    def find_sql(limit, offset: 0)
      self.class._base_sql(@founder, sql, '', order, limit, offset)
    end

    def find_with_meta_sql(limit, offset: 0)
      self.class._base_sql(@founder, sql, meta_sql, order, limit, offset)
    end

    def fetch_result_count
      Competitor.count_by_sql count_sql
    end

    def result_count
      if cached?
        Rails.cache.fetch(cache_key('count')) || 0
      else
        fetch_result_count
      end
    end

    def fetch_results(limit, offset, meta, json: nil)
      if meta
        mapper = json.present? ? "as_#{json}_json".to_sym : :as_meta_json
        Competitor.find_by_sql(find_with_meta_sql(limit, offset: offset)).map(&mapper)
      else
        mapper = json.present? ? "as_#{json}_json".to_sym : :as_json
        Competitor.find_by_sql(find_sql(limit, offset: offset)).map(&mapper)
      end
    end

    def targets_for_investors(investors)
      return {} unless @founder.present?
      sql = <<-SQL
        SELECT results.id AS competitor_id, ti.*
        FROM (
          SELECT competitors.id FROM competitors
          WHERE competitors.id IN (#{investors.map { |r| r['id'] }.join(',')})
        ) AS results
        #{self.class.target_investor_sql(@founder, 'results')}
      SQL
      Competitor.connection.execute(sql).group_by { |r| r['competitor_id'] }
    end

    def fetch_cached_results
      results = Rails.cache.fetch(cache_key('results'))
      targets = targets_for_investors(results)
      results.each do |competitor|
        meta = targets[competitor['id']]&.first
        competitor['target_investor'] = if meta.present? && meta['id'].present?
          { id: meta['id'], stage: TargetInvestor.stages.invert[meta['stage']] }
        else
          nil
        end
      end
    end

    def results(limit: GET_LIMIT, offset: 0, meta: false, json: nil)
      if cached?
        fetch_cached_results
      else
        fetch_results(limit, offset, meta, json: json)
      end
    end

    def cache!(limit: GET_LIMIT * 2, offset: 0)
      results = fetch_results(limit, offset, true, json: 'cached_meta')
      Rails.cache.write(cache_key('results'), results)
      Rails.cache.write(cache_key('count'), results.count)
    end
  end

  class Base
    extend ClassSetup
    extend ClassSql
    extend ClassBulk
    include Results

    attr_reader :founder

    def initialize(founder, request)
      @founder = founder
      @request = request
    end

    def sql
      raise 'must implement sql'
    end

    def meta_sql
    end

    def meta_cols
    end

    def order
    end

    def title
      self.class.title
    end

    def to_param
      self.class.name.demodulize.underscore.to_sym
    end

    def as_json(opts = {})
      {
        competitors: results(**opts),
        columns: meta_cols,
        count: result_count,
        title: title,
        name: to_param
      }
    end
  end
end