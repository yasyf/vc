class CompetitorLists::MostPopularOf < CompetitorLists::MostPopular
  def title
    "#{Competitor::FUND_TYPES[cache_values[:fund_type]]} Investors that are popular"
  end

  def self.derived?
    false
  end

  def self._eligible?(attrs)
    attrs[:fund_type].present?
  end

  def self.cache_values_span
    Competitor::FUND_TYPES.keys.map { |t| { fund_type: t } }
  end

  def self.cache_key_attrs
    {}
  end

  def self.cache_key_fallbacks
    {}
  end

  def self._sql(attrs)
    Competitor
      .where('competitors.fund_type && ?', "{#{attrs[:fund_type]}}")
      .joins(:companies)
      .joins(:investors)
      .order('ti_sum DESC, c_cnt DESC')
      .group('competitors.id')
      .select('competitors.id', 'COALESCE(SUM(investors.target_investors_count), 0) AS ti_sum', 'COUNT(companies.id) AS c_cnt')
      .limit(10)
      .to_sql
  end
end

%w(angel seed).each do |fund_type|
  klass = Class.new(CompetitorLists::MostPopularOf) do
    define_singleton_method(:fund_type) { fund_type }

    def self.derived?
      true
    end

    def self.cache_key_attrs
      {
        fund_type: Proc.new { |founder| fund_type }
      }
    end

    def self.cache_key_fallbacks
      {
        fund_type: Proc.new { |request| fund_type }
      }
    end
  end
  CompetitorLists.const_set("MostPopularOf#{fund_type.titleize}", klass)
end