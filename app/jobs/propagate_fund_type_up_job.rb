class PropagateFundTypeUpJob < ApplicationJob
  FUND_TYPE_THRESHOLD = 0.25

  queue_as :low

  def perform(name, relations)
    propagate_fund_type_up name.constantize, relations
  end

  private

  def propagate_fund_type_up(klass, relations)
    #TODO: do this in sql
    klass.where(verified: false).find_each do |c|
      fund_types = Hash.new(0)
      count = 0
      relations.each do |relation|
        c.public_send(relation).find_each do |i|
          count += 1
          i.fund_type.each do |ft|
            fund_types[ft] += 1
          end if i.fund_type.present?
        end
      end
      next unless fund_types.present?
      fund_type = fund_types.keys.select { |ft| fund_types[ft] > FUND_TYPE_THRESHOLD * count }
      c.fund_type = fund_type if fund_type.present?
      c.save! if c.changed?
    end
  end
end
