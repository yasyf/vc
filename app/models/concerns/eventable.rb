module Concerns
  module Eventable
    extend ActiveSupport::Concern

    included do
      has_many :events, as: :subject
      @event_names = []
    end

    class_methods do
      def event_names
        @event_names
      end

      def action(*actions)
        Array.wrap(actions).each do |action|
          @event_names << action
         define_method("#{action}!") do |*args|
            attrs = args.map.with_index { |x,i| ["arg#{i + 1}", x] }.to_h
            Event.create!(attrs.merge(subject: self, action: action))
          end
        end
      end

      alias_method :actions, :action
    end
  end
end
