module CompetitorLists::Base::ClassBulk
  def get_if_eligible(founder, request, name)
    @lists.find { |l| l.to_param == name.to_sym && l.eligible?(founder, request) }
  end

  def get_eligibles(founder, request)
    @lists.select { |l| l.eligible? founder, request }
  end

  def _eligible?(attrs)
    true
  end

  def eligible?(founder, request)
    _eligible?(cache_values(founder, request))
  end

  def cache_key_attrs
    nil
  end

  def cache_key_fallbacks
    {}
  end

  def cache_values(founder, request)
    return {} unless cache_key_attrs.is_a?(Array)
    cache_key_attrs.map do |a|
      result = founder.present? ? founder.send(a).to_s : nil
      if result.blank? && request.present? && cache_key_fallbacks[a].present?
        result = cache_key_fallbacks[a].call(request)
      end
      [a, result]
    end.to_h
  end

  def cache_key(founder, request, name)
    return nil unless cache_key_attrs.present?
    keys = ['competitor_lists', to_param, name]
    keys += cache_values(founder, request).sort.map(&:last)
    keys.join('/')
  end

  def title
    self::TITLE
  end

  def to_param
    self.name.demodulize.underscore.to_sym
  end
end