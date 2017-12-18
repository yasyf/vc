module Http::Crunchbase
  class ApiObject
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def method_missing(name, *args)
      get_property(name) || get_relationship(name) || get_value(name)
    end

    def get_property(name)
      child properties[name.to_s]
    end

    alias_method :prop, :get_property

    def get_relationship(name)
      result = relationships[name.to_s]
      if result.is_a?(Array)
        children result
      elsif result&.key?('items')
        children result['items']
      else
        child result['item']
      end
    end

    alias_method :rel, :get_relationship

    %w(properties relationships).each do |name|
      define_method(name) { get_hash(name) }
    end

    def present?
      @response.present?
    end

    private

    def children(arr)
      return [] unless arr.present?
      arr.map { |resp| child(resp) if resp.present? }
    end

    def child(resp)
      return nil unless resp.present?
      resp.is_a?(Hash) ? self.class.new(resp) : resp
    end

    def get_hash(name)
      get_value(name) || {}
    end

    def get_value(name)
      @response[name.to_s]
    end
  end
end
