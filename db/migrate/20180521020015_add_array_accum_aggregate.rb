class AddArrayAccumAggregate < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      CREATE AGGREGATE array_accum (anyarray)
      (
          sfunc = array_cat,
          stype = anyarray,
          initcond = '{}'
      );
    SQL
  end
end
