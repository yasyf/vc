module Concerns
  module AttributeSortable
    extend ActiveSupport::Concern

    included do
      @sorted_attributes = []

      before_save :split_and_sort
    end

    class_methods do
      def sort(name, split: ',')
        @sorted_attributes << {name: name, split: split}
      end

      def sorted_attributes
        @sorted_attributes
      end
    end

    def split_and_sort
      self.class.sorted_attributes.each do |sa|
        next unless (attr = self[sa[:name]]).present?
        self[sa[:name]] = attr.split(sa[:split]).sort.join(sa[:split])
      end
    end
  end
end
