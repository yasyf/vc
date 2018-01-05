module Concerns
  module AttributeArrayable
    extend ActiveSupport::Concern

    included do
      @array_attributes = []

      before_save :clean_arrays
    end

    class_methods do
      def array(name)
        @array_attributes << name

        define_method "#{name}=" do |new_attr|
          if new_attr.is_a?(String)
            super new_attr.split(',')
          else
            super new_attr
          end
        end
      end

      def array_attributes
        @array_attributes
      end
    end

    def clean_arrays
      self.class.array_attributes.each do |attr|
        next unless self[attr].present?
        self[attr] = self[attr].uniq
      end
    end
  end
end
