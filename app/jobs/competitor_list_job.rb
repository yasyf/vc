class CompetitorListJob < ActiveJob::Base
  queue_as :default

  def perform
    CompetitorLists::Base::Base.lists.each { |list| cache_list! list }
  end

  private

  def cache_list!(list)
    return unless list.cache_key_attrs.present?
    return if list.derived?
    list.cache_values_span.each do |cache_values|
      instance = list.new(nil, nil)
      instance.cache_values = cache_values
      instance.cache!
    end
  end
end
