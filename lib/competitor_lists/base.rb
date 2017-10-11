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
  def self.eligibles(founder)
    @lists.select { |l| l.eligible? founder }
  end

  def self.title
    self::TITLE
  end

  def self.to_param
    name.demodulize.underscore
  end

  def self.result_count
    Competitor.connection.select_value count_sql
  end

  def self.results(limit)
    Competitor.find_by_sql limited_sql(limit)
  end

  def self.count_sql
    <<-SQL
      SELECT COUNT(*)
      FROM (#{sql}) AS subquery
    SQL
  end

  def self.limited_sql(limit)
    <<-SQL
      SELECT id, name, photo
      FROM (#{sql}) AS subquery
      LIMIT #{limit}
    SQL
  end

  def self.sql
    raise 'must implement sql'
  end

  def self.eligible?(founder)
    true
  end
end