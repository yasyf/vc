class CompetitorLists::MostRecentIn < CompetitorLists::MostRecent
  def self.derived?
    false
  end

  def description
    "These are some of the hottest, most recent investments in #{Competitor::INDUSTRIES[cache_values[:industry]]}. This space really seems to be heating up!"
  end

  def title
    "#{TITLE} in #{Competitor::INDUSTRIES[cache_values[:industry]]}"
  end

  def self._eligible?(attrs)
    attrs[:industry].present?
  end

  def self.cache_values_span
    Competitor::INDUSTRIES.keys.map { |i| { industry: i } }
  end

  def self.cache_key_attrs
    {}
  end

  def self.cache_key_fallbacks
    {}
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
  klass = Class.new(CompetitorLists::MostRecentIn) do
    define_singleton_method(:arg_count) { count }

    def self.derived?
      true
    end

    def self.personalized?
      true
    end

    def self.cache_key_attrs
      {
        industry: lambda do |founder|
          return nil unless (company = founder.primary_company).present?
          company.industry[arg_count]
        end
      }
    end
  end
  CompetitorLists.const_set("MostRecentInCompany#{count}", klass)
end

%w(bitcoin ai arvr).each do |industry|
  klass = Class.new(CompetitorLists::MostRecentIn) do
    define_singleton_method(:industry) { industry }

    def self.eligible?(founder, request)
      return true unless (company = founder.primary_company).present?
      !company.industry.include?(industry)
    end

    def self.derived?
      true
    end

    def self.cache_key_attrs
      {
        industry: Proc.new { |founder| industry }
      }
    end

    def self.cache_key_fallbacks
      {
        industry: Proc.new { |request| industry }
      }
    end
  end
  CompetitorLists.const_set("MostRecentIn#{industry.titleize}", klass)
end