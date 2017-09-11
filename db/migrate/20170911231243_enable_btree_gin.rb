class EnableBtreeGin < ActiveRecord::Migration[5.0]
  def self.up
    ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS btree_gin;')
  end

  def self.down
    ActiveRecord::Base.connection.execute('DROP EXTENSION btree_gin;')
  end
end
