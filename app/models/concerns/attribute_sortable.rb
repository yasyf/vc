module Concerns
  module AttributeSortable
    extend ActiveSupport::Concern

    included do
      @sorted_attributes = []

      before_save :sort_sortables
    end

    class_methods do
      def sort(name)
        @sorted_attributes << name

        define_method "#{name}=" do |new_attr|
          if new_attr.is_a?(String)
            super new_attr.split(',')
          else
            super new_attr
          end
        end
      end

      def sorted_attributes
        @sorted_attributes
      end
    end

    def sort_sortables
      self.class.sorted_attributes.each do |attr|
        next unless self[attr].present?
        self[attr] = self[attr].sort.uniq
      end
    end
  end
end
