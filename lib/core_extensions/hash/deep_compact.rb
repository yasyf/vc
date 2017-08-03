module CoreExtensions
  module Hash
    module DeepCompact
      def deep_compact
        self.each_with_object({}) do |(k,v), h|
          next if v.nil?
          if v.is_a?(::Hash)
            val = v.deep_compact
            h[k] = val unless val.blank?
          else
            h[k] = v
          end
        end
      end
    end
  end
end
