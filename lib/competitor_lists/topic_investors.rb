class CompetitorLists::TopicInvestors < CompetitorLists::Base::Base
  TITLE = 'Investors who talk about'

  def entity
    @entity ||= Entity.where(name: cache_values[:topic]).first!
  end

  def title
    "#{TITLE} #{entity.nice_name}"
  end

  def description
    """
      These are all the investors who often talk about #{entity.nice_name}.
      Seems like quite a hot topic these days!
    """
  end

  def self._eligible?(attrs)
    false
  end

  def self.matches?
    true
  end

  def self.cache_key_attrs
    {}
  end

  def _sql
    <<-SQL
      SELECT
        investor_entities.competitor_id AS id,
        investor_entities.investor_id AS match_id,
        investor_entities.count AS entities_count
      FROM investor_entities
      WHERE investor_entities.entity_id = #{entity.id}
    SQL
  end

  def sort
    <<-SQL
      MAX(subquery.entities_count) DESC
    SQL
  end

  def order_sql
    <<-SQL
      row_number() OVER (ORDER BY #{sort}) AS rn
    SQL
  end

  def with_order_subquery
    <<-SQL
      SELECT subquery.id, array_agg(DISTINCT COALESCE(subquery.match_id)) AS matches, #{order_sql}
      FROM (#{_sql}) AS subquery
      GROUP BY subquery.id
    SQL
  end

  def sql
    <<-SQL
      SELECT competitors.*, wo.id AS investment_id, wo.rn, wo.matches
      FROM (#{with_order_subquery}) AS wo
      INNER JOIN competitors ON competitors.id = wo.id
    SQL
  end

  def order
    :rn
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