class CompetitorLists::Filtered < CompetitorLists::Base
  TITLE = 'Filtered'

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def self._eligible?(attrs)
    false
  end

  def _filtered_by_search_subquery
    name = Util.escape_sql_argument(params[:search])
    first_name, last_name = Util.split_name(params[:search]).map(&Util.method(:escape_sql_argument))
    last_name = first_name unless last_name.present?
    competitors_subquery = <<-SQL
      SELECT
        competitors.id as id,
        COALESCE(similarity(competitors.name, '#{name}'), 0) AS rank
      FROM competitors
      WHERE competitors.name % '#{name}'
      ORDER BY rank DESC
    SQL
    investors_subquery = <<-SQL
      SELECT
        competitors.id AS id,
        investors.id AS match_id,
        COALESCE(similarity(investors.first_name, '#{first_name}'), 0) + COALESCE(similarity(investors.last_name, '#{last_name}'), 0) AS rank
      FROM investors
      INNER JOIN competitors on investors.competitor_id = competitors.id
      WHERE
        investors.first_name % '#{first_name}'
        #{first_name == last_name ? 'OR' : 'AND'} investors.last_name % '#{last_name}'
      ORDER BY rank DESC
    SQL
    <<-SQL
      SELECT COALESCE(csub.id, isub.id) AS id, isub.match_id
      FROM (#{competitors_subquery}) AS csub
      FULL JOIN (#{investors_subquery}) AS isub USING (id)
      ORDER BY csub.rank + isub.rank
    SQL
  end

  def _filtered_by_related_subquery
    industry_subquery = <<-SQL
      SELECT array_agg(related_industries)
      FROM (
        SELECT DISTINCT unnest(companies.industry)
        FROM companies
        WHERE companies.id IN (#{Util.escape_sql_argument(params[:companies])})
      ) AS t(related_industries)
    SQL
    <<-SQL
      SELECT companies.id
      FROM companies
      WHERE
        companies.industry <> '{}'
        AND companies.industry IS NOT NULL
        AND companies.industry <@ (#{industry_subquery})
    SQL
  end

  def _filtered
    competitors = if params[:search].present?
      Competitor.joins("INNER JOIN (#{_filtered_by_search_subquery}) AS searched ON competitors.id = searched.id")
    else
      Competitor.all
    end
    %w(fund_type).each do |param|
      next unless params[param].present?
      competitors = competitors.where("competitors.#{param} && ?", "{#{params[param]}}")
    end
    if params[:industry].present?
      competitors = competitors.where('competitors.industry @> ?', "{#{params[:industry]}}")
    end
    if params[:location].present?
      competitors = if params[:company_cities]
        competitors.joins(:companies).where('companies.location IN (?)', params[:location])
      else
        competitors.where('competitors.location && ?', "{#{params[:location]}}")
      end
    end
    if params[:companies].present?
      competitors = competitors.joins(:companies)
      competitors = if params[:related]
        competitors.joins("INNER JOIN (#{_filtered_by_related_subquery}) AS related_companies ON companies.id = related_companies.id")
      else
        competitors.where('companies.id': params[:companies].split(','))
      end
    end
    competitors = competitors.where(country: 'US') if params[:us_only]
    competitors.left_outer_joins(:investors)
  end

  def sort
    <<-SQL
      COUNT(NULLIF(investors.featured, false)) DESC, COALESCE(SUM(investors.target_investors_count), 0) DESC
    SQL
  end

  def order_sql
    <<-SQL
      , row_number() OVER (ORDER BY #{sort}) AS rn
    SQL
  end

  def match_sql
    params[:search].present? ? ', array_agg(DISTINCT searched.match_id) AS matches' : ''
  end

  def sql
    _filtered.group('competitors.id').select("competitors.*#{match_sql}#{order_sql}").to_sql
  end

  def order
    :rn
  end
end