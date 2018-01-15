class CompetitorLists::CompanyInvestors < CompetitorLists::Base::Base
  TITLE = 'Firms that invested'

  def company
    @company ||= Company.find(cache_values[:company_id])
  end

  def title
    "#{TITLE} in #{company.name}"
  end

  def description
    """
      These are all the firms that invested in #{@founder.present? ? 'your competitor' : ''} #{company.name},
      ordered by how recently they've made an investment.
      It pays to keep an eye on the competition!
    """
  end

  def self._eligible?(attrs)
    false
  end

  def self.cache_key_attrs
    {}
  end

  def self.cache_values_span
    company_ids = Founder.active.pluck('DISTINCT companies.id')
    Competition.for_companies(company_ids).pluck('DISTINCT companies.id').map { |v| { company_id: v } }
  end

  def self._sql(attrs)
    <<-SQL
      SELECT DISTINCT ON(investments.competitor_id) id, funded_at, competitor_id
      FROM investments
      WHERE investments.company_id = #{attrs[:company_id]}
      ORDER BY investments.competitor_id, investments.funded_at DESC
    SQL
  end

  def _sql
    self.class._sql(cache_values)
  end

  def sort
    <<-SQL
      subquery.funded_at DESC NULLS LAST
    SQL
  end

  def order_sql
    <<-SQL
      row_number() OVER (ORDER BY #{sort}) AS rn
    SQL
  end

  def with_order_subquery
    <<-SQL
      SELECT subquery.id, subquery.competitor_id, #{order_sql}
      FROM (#{_sql}) AS subquery
    SQL
  end

  def sql
    <<-SQL
      SELECT competitors.*, wo.id AS investment_id, wo.rn
      FROM (#{with_order_subquery}) AS wo
      INNER JOIN competitors ON competitors.id = wo.competitor_id
    SQL
  end

  def order
    :rn
  end

  def meta_sql
    <<-SQL
      SELECT investments.funded_at
      FROM investments
      WHERE investments.id = subquery.investment_id
    SQL
  end

  def meta_cols
    [
      {
        key: :funded_at,
        name: 'Funding Date',
        type: :datetime,
      },
    ]
  end
end

(0...3).each do |count|
  klass = Class.new(CompetitorLists::CompanyInvestors) do
    define_singleton_method(:arg_count) { count }

    def self.derived?
      true
    end

    def self.personalized?
      true
    end

    def self.cache_key_attrs
      {
        company_id: lambda do |founder|
          return nil unless (company = founder.primary_company).present?
          company.competitions.order(:id).offset(arg_count).limit(1).pluck(:id).first
        end
      }
    end

    def self._eligible?(attrs)
      return false unless attrs[:company_id].present?
      sql = <<-SQL
        SELECT COUNT(*) FROM (#{_sql(attrs)}) AS subquery
      SQL
      Competitor.connection.select_value(sql) > 0
    end
  end
  CompetitorLists.const_set("CompanyInvestors#{count}", klass)
end