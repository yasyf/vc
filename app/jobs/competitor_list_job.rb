class CompetitorListJob < ActiveJob::Base
  queue_as :default

  def perform
    CompetitorLists::Base.lists.each { |list| cache_list! list }
  end

  private

  def cache_list!(list)
    return unless (attrs = list.cache_key_attrs).present?
    eligibles = if attrs.is_a?(Array)
      Founder.select("DISTINCT ON (#{attrs.join(', ')}) *")
    else
      Founder.limit(1)
    end
    eligibles.to_a.select { |f| list.eligible?(f, nil) }.each do |founder|
      list.new(founder, nil).cache!
    end
  end
end
