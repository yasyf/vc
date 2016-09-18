class AddUniqueIndices < ActiveRecord::Migration[5.0]
  def change
    add_uniq! Company, :trello_id
    add_uniq! Company, :snapshot_link
    add_uniq! Company, :domain
    add_uniq! Company, :crunchbase_id
    add_uniq! User, :trello_id
    add_uniq! User, :username
    add_uniq! User, :slack_id
    add_uniq! User, :cached_name
    add_uniq! Knowledge, :ts
    add_uniq! List, :trello_id
    add_uniq! Team, :name
  end

  private

  def transfer_assoc(assoc, keep, records)
    Array.wrap(records).each do |record|
      record.skip_eligibility! if record.is_a?(Vote)
      begin
        record.update! assoc.inverse_of.name => keep
      rescue ActiveRecord::RecordInvalid
        record.destroy!
      end
    end
  end

  def add_uniq!(klass, column)
    klass.all.group_by(&column).select { |c, r| c.present? && r.count > 1 }.each do |_, records|
      keep = records.pop
      records.each do |record|
        klass.reflect_on_all_associations.each do |assoc|
          case assoc.macro
            when :has_many
              transfer_assoc assoc, keep, record.send(assoc.name)
            when :has_one
              transfer_assoc assoc, keep, record.send(assoc.name)
          end
        end
        record.destroy!
      end
    end
    remove_index klass.table_name, column if index_exists?(klass.table_name, column)
    add_index klass.table_name, column, unique: true
  end
end
