class CompetitorLists::MostRecentIndustry < CompetitorLists::MostRecent
  def self.derived?
    false
  end

  def title
    "#{TITLE} in #{Competitor::INDUSTRIES[cache_values[:industry]]}"
  end

  def self._eligible?(attrs)
    false
  end

  def self.cache_values_span
    Competitor::INDUSTRIES.keys.map { |i| { industry: i } }
  end

  def limited_sql
    <<-SQL
      SELECT investments.id
      FROM investments
      INNER JOIN companies ON companies.id = investments.company_id
      WHERE companies.industry @> '{#{cache_values[:industry]}}'
      ORDER BY funded_at DESC NULLS LAST
      LIMIT 100
    SQL
  end
end

(0...3).each do |count|
  klass = Class.new(CompetitorLists::MostRecentIndustry) do
    define_singleton_method(:arg_count) { count }

    def self.derived?
      true
    end

    def self.cache_key_attrs
      {
        industry: Proc.new { |founder| founder.primary_company.industry[arg_count] }
      }
    end

    def self._eligible?(attrs)
      attrs[:industry].present?
    end
  end
  CompetitorLists.const_set("MostRecentIndustry#{count}", klass)
end

%w(bitcoin).each do |industry|
  klass = Class.new(CompetitorLists::MostRecentIndustry) do
    define_singleton_method(:industry) { industry }

    def self.derived?
      true
    end

    def self.cache_key_attrs
      {
        industry: Proc.new { |founder| industry }
      }
    end

    def self._eligible?(attrs)
      true
    end
  end
  CompetitorLists.const_set("MostRecentIndustry#{industry.titleize}", klass)
end