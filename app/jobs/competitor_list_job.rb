class CompetitorListJob < ActiveJob::Base
  queue_as :high_mem

  def perform
    CompetitorLists::Base::Base.lists.each { |list| cache_list! list }
  end

  private

  def cache_list!(list)
    return if list.cache_key_attrs.nil?
    return if list.derived?
    if list.cache_key_attrs.is_a?(TrueClass)
      list.new(nil, nil).cache!
    else
      list.cache_values_span.each do |cache_values|
        instance = list.new(nil, nil)
        instance.cache_values = cache_values
        instance.cache!
      end
    end
  end
end
