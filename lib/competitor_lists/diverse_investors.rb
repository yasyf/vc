class CompetitorLists::DiverseInvestors < CompetitorLists::Base::Base
  TITLE = 'Investors identified by Founders for Change as diverse'

  def description
    """
    These investors have been identified by our partners at
    <a href='https://www.foundersforchange.org'>Founders for Change</a>
    as being diverse individuals.
    """
  end

  def self._eligible?(attrs)
    true
  end

  def self.matches?
    true
  end

  def self.cache_values_span
    []
  end

  def self.cache_key_attrs
    true
  end

  def self.cache_key_fallbacks
    {}
  end

  def _sql
    <<-SQL
      SELECT
        investors.competitor_id AS id,
        investors.id AS match_id
      FROM investors
      WHERE investors.tags IS NOT NULL
    SQL
  end

  def sql
    <<-SQL
      SELECT competitors.*, array_agg(DISTINCT COALESCE(subquery.match_id)) AS matches
      FROM (#{_sql}) AS subquery
      INNER JOIN competitors ON competitors.id = subquery.id
      GROUP BY competitors.id
    SQL
  end

  def meta_cols
    [
      {
        key: 'matched_partners[0].full_name',
        name: 'Partner',
        type: :partner,
        noPrefix: true,
        imageKey: 'matched_partners[0].photo',
        verifiedKey: 'matched_partners[0].verified',
        subKey: 'matched_partners[0].role',
        fallbackFnKey: 'matched_partners[0]',
      },
    ]
  end
end
