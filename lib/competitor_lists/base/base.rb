module CompetitorLists::Base
  class Base
    extend ClassSetup
    extend ClassSql
    extend ClassBulk
    extend ClassSortable
    include InstanceResults

    attr_reader :founder

    def initialize(founder, request)
      @founder = founder
      @request = request
    end

    def sql
      raise 'must implement sql'
    end

    def meta_sql
    end

    def meta_cols
    end

    def order
    end

    def title
      self.class.title
    end

    def description
      self.class.description
    end

    def to_param
      self.class.to_param
    end

    def as_json(opts = {})
      {
        competitors: results(**opts),
        columns: meta_cols,
        count: result_count,
        title: title,
        heading: title.titleize,
        description: description,
        name: to_param,
        cached: was_cached?,
        personalized: self.class.personalized?,
      }
    end
  end
end