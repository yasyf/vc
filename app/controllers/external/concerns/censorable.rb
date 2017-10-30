module External::Concerns
  module Censorable
    extend ActiveSupport::Concern

    included do
      @filtered_paths = []
    end

    class_methods do
      def filter(path)
        @filtered_paths += Array.wrap(path)
      end

      def filtered_paths
        @filtered_paths
      end
    end

    def render_censored(models)
      filtered = Array.wrap(models).map do |model|
        filter_unless_portfolio(self.class.filtered_paths, model)
      end
      render json: (models.is_a?(ApplicationRecord) || models.is_a?(Hash)) ? filtered.first : filtered
    end

    def filter_unless_portfolio(paths, object)
      base = JSON.parse object.to_json
      return base if current_external_founder&.drf?

      paths.each do |path|
        components = path.to_s.split('.')
        current = base
        current = current[components.shift] while components.length > 1
        current.delete(components.last)
      end

      base
    end
  end
end
