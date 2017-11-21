module CompetitorLists::Base::InstanceResults
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

  def find_sql(limit, offset: 0, sort: nil)
    self.class._base_sql(
      @founder,
      sql,
      '',
      sort.present? ? self.class.order_sql_from_sort(sort) : self.order,
      limit,
      offset,
      include_targets: sort && sort.include?(:stage)
    )
  end

  def find_with_meta_sql(limit, offset: 0, sort: nil)
    self.class._base_sql(
      @founder,
      sql,
      meta_sql,
      sort.present? ? self.class.order_sql_from_sort(sort) : self.order,
      limit,
      offset,
      include_targets: sort && sort.include?(:stage)
    )
  end

  def fetch_result_count
    Competitor.count_by_sql count_sql
  end

  def result_count
    if cached?
      count = Rails.cache.fetch(cache_key('count'))
      count.present? ? count : 0
    else
      fetch_result_count
    end
  end

  def fetch_results(limit, offset, meta, json: nil, sort: nil)
    if meta
      mapper = json.present? ? "as_#{json}_json".to_sym : :as_meta_json
      Competitor.find_by_sql(find_with_meta_sql(limit, offset: offset, sort: sort)).map(&mapper)
    else
      mapper = json.present? ? "as_#{json}_json".to_sym : :as_json
      Competitor.find_by_sql(find_sql(limit, offset: offset, sort: sort)).map(&mapper)
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
    return [] unless results.present?
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

  def results(sort: nil, limit: GET_LIMIT, offset: 0, meta: false, json: nil)
    if cached?
      fetch_cached_results
    else
      fetch_results(limit, offset, meta, json: json, sort: sort)
    end
  end

  def cache!(limit: GET_LIMIT * 2, offset: 0)
    results = fetch_results(limit, offset, true, json: 'cached_meta')
    Rails.cache.write(cache_key('results'), results)
    Rails.cache.write(cache_key('count'), results.count)
  end
end