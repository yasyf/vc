class CompetitorLists::Base
  def self.inherited(klass)
    @lists << klass
  end

  def self.init
    @lists = []
    Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file|
      next if file == __FILE__
      require_dependency file
    end
  end

  init
end

class CompetitorLists::Base
  GET_LIMIT = 5

  def self.get_if_eligible(founder, name)
    @lists.find { |l| l.to_param == name.to_sym && l.eligible?(founder) }
  end

  def self.get_eligibles(founder)
    @lists.select { |l| l.eligible? founder }
  end

  def self.eligible?(founder)
    true
  end

  def self.title
    self::TITLE
  end

  def self.to_param
    self.name.demodulize.underscore.to_sym
  end

  def self.track_status_sql(competitors_table = 'competitors')
    <<-SQL
      LEFT JOIN LATERAL (
        SELECT target_investors.stage as stage
        FROM investors
        INNER JOIN target_investors ON target_investors.investor_id = investors.id
        WHERE investors.competitor_id = #{competitors_table}.id
        ORDER BY target_investors.updated_at DESC
        LIMIT 1
      ) AS stages ON true
    SQL
  end

  def self._base_sql(sql, meta_sql, limit, offset)
    <<-SQL
      SELECT DISTINCT ON (subquery.id) subquery.*, stages.stage as track_status, row_to_json(meta_row.*) AS meta
      FROM (#{sql}) AS subquery
      LEFT OUTER JOIN investors ON investors.competitor_id = subquery.id
      #{track_status_sql('subquery')}
      LEFT JOIN LATERAL (#{meta_sql}) meta_row ON true
      OFFSET #{offset}
      LIMIT #{limit}
    SQL
  end

  def initialize(founder)
    @founder = founder
  end

  def result_count
    Competitor.connection.select_value count_sql
  end

  def results(limit: GET_LIMIT, offset: 0, meta: false, json: nil)
    if meta
      mapper = json.present? ? "as_#{json}_json".to_sym : :as_meta_json
      Competitor.find_by_sql(find_with_meta_sql(limit, offset: offset)).map(&mapper)
    else
      mapper = json.present? ? "as_#{json}_json".to_sym : :as_json
      Competitor.find_by_sql(find_sql(limit, offset: offset)).map(&mapper)
    end
  end

  def count_sql
    <<-SQL
      SELECT COUNT(DISTINCT subquery.id)
      FROM (#{sql}) AS subquery
    SQL
  end

  def find_sql(limit, offset: 0)
    self.class._base_sql(sql, '', limit, offset)
  end

  def find_with_meta_sql(limit, offset: 0)
    self.class._base_sql(sql, meta_sql, limit, offset)
  end

  def sql
    raise 'must implement sql'
  end

  def meta_sql
    raise 'must implement meta_sql'
  end
  def meta_cols
    raise 'must implement meta_cols'
  end

  def title
    self.class.title
  end

  def to_param
    self.class.title
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