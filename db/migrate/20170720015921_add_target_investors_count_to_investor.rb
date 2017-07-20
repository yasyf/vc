class AddTargetInvestorsCountToInvestor < ActiveRecord::Migration[5.1]
  def change
    add_column :investors, :target_investors_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE investors
            SET target_investors_count = (SELECT count(*) 
                                          FROM target_investors
                                          WHERE target_investors.investor_id = investors.id)
        SQL
      end
    end
  end
end
