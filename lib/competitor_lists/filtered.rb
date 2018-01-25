class CompetitorLists::Filtered < CompetitorLists::Base::Base
  TITLE = 'Filtered'

  attr_reader :params

  def initialize(founder, request, params)
    super founder, request
    @params = params
  end

  def self._eligible?(attrs)
    false
  end

  def _filtered_by_search_subquery(search)
    <<-SQL
      SELECT
        competitors.id AS id,
        investors.id AS match_id,
        #{[
          search[:first_name] && Util.sanitize_sql('COALESCE(similarity(investors.first_name, ?), 0)', search[:first_name]),
          search[:last_name] && Util.sanitize_sql('COALESCE(similarity(investors.last_name, ?), 0)', search[:last_name]),
          search[:firm_name] && Util.sanitize_sql('COALESCE(similarity(competitors.name, ?), 0)', search[:firm_name]),
        ].compact.join(' + ')} AS rank
      FROM investors
      INNER JOIN competitors on investors.competitor_id = competitors.id
      WHERE
        #{[
          search[:first_name] && Util.sanitize_sql('((investors.first_name % ?) OR (investors.first_name ILIKE ?))', search[:first_name], "#{search[:first_name]}%"),
          search[:last_name] && Util.sanitize_sql('((investors.last_name % ?) OR (investors.last_name ILIKE ?))', search[:last_name], "#{search[:last_name]}%"),
          search[:firm_name] && Util.sanitize_sql('((competitors.name % ?) OR (competitors.name ILIKE ?))', search[:firm_name], "#{search[:firm_name]}%"),
        ].compact.join(' AND ')}
      ORDER BY rank DESC
    SQL
  end

  def _filtered_by_related_subquery
    industry_subquery = <<-SQL
      SELECT array_agg(related_industries)
      FROM (
        SELECT DISTINCT unnest(companies.industry)
        FROM companies
        WHERE companies.id IN (#{Util.escape_sql_argument(params[:filters][:companies])})
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

  def _industry_overlap_subquery
    count_subquery = <<-SQL
      SELECT COUNT(*) AS overlap_cnt
      FROM unnest(competitors.industry) AS compet_ind
      WHERE compet_ind = ANY('{#{overlap_industries}}')
    SQL
    <<-SQL
      LEFT JOIN LATERAL (#{count_subquery}) AS overlap_counts ON true
    SQL
  end

  def overlap_industries
    @overlap_industries ||= begin
      if params[:filters][:industry].present?
        params[:filters][:industry]
      elsif @founder.present? && @founder.primary_company.present? && @founder.primary_company.industry.present?
        @founder.primary_company.industry.join(',')
      end
    end
  end

  def overlap_cities
    @overlap_cities ||= begin
      if params[:filters][:location].present?
        params[:filters][:location]
      elsif @request.session[:city].present?
        @request.session[:city]
      elsif @founder.present? && founder.city.present?
        founder.city.present?
      end
    end
  end

  def _filtered
    competitors = if params[:search].present?
      Competitor.joins("INNER JOIN (#{_filtered_by_search_subquery(params[:search])}) AS searched ON competitors.id = searched.id")
    else
      Competitor.all
    end
    competitors = competitors.where('competitors.fund_type && ?', "{#{params[:filters][:fund_type]}}") if params[:filters][:fund_type].present?
    if params[:filters][:industry].present?
      if params[:options][:industry_or]
        competitors = competitors.where('competitors.industry && ?', "{#{params[:filters][:industry]}}")
      else
        competitors = competitors.where('competitors.industry @> ?', "{#{params[:filters][:industry]}}")
      end
    end
    if params[:filters][:location].present?
      competitors = if params[:options][:company_cities]
        competitors.joins(:companies).where('companies.location = ANY(ARRAY[?])', params[:filters][:location])
      else
        competitors.where('competitors.location && ?', "{#{params[:filters][:location]}}")
      end
    end
    if params[:filters][:companies].present?
      competitors = competitors.joins(:companies)
      competitors = if params[:options][:related]
        competitors.joins("INNER JOIN (#{_filtered_by_related_subquery}) AS related_companies ON companies.id = related_companies.id")
      else
        competitors.where('companies.id': params[:filters][:companies].split(','))
      end
    end
    competitors = competitors.where(country: 'US') if params[:options][:us_only]
    competitors = competitors.joins(_industry_overlap_subquery) if overlap_industries.present?
    competitors.joins('INNER JOIN competitor_investor_aggs ON competitor_investor_aggs.competitor_id = competitors.id')
  end

  def sort
    [
      'bool_or(COALESCE(competitor_investor_aggs.featured, false)) DESC',
      overlap_industries.present? && 'MIN(overlap_cnt) DESC',
      overlap_cities.present? && "(#{Util.sanitize_sql('competitors.location && ARRAY[?]::character varying[]', overlap_cities)}) DESC",
      'SUM(COALESCE(competitor_investor_aggs.target_count, 0)) DESC',
      'bool_or(COALESCE(competitor_investor_aggs.verified, false)) DESC',
    ].select { |x| x }.join(', ')
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
    _filtered.group('competitors.id').select("competitors.*#{match_sql}#{order_sql}").limit(500).to_sql
  end

  def order
    :rn
  end
end