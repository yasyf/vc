module Concerns
  module Eventable
    extend ActiveSupport::Concern

    class_methods do

      def action(actions)
        Array.wrap(actions).each do |action|
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
