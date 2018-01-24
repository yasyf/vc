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
            self.mixpanel.track(self.id, action, {args: args}) if self.mixpanel.present?
          end
        end
      end

      def mixpanel_consumer
        @mixpanel_consumer ||= Mixpanel::BufferedConsumer.new.tap do |buffered_consumer|
          at_exit { buffered_consumer.flush }
        end
      end

      alias_method :actions, :action
    end

    def mixpanel
      @mixpanel ||= Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN']) do |type, message|
        self.class.mixpanel_consumer.send!(type, message)
      end.tap do |tracker|
        tracker.people.set(self.id, {
          id: self.id,
          name: self.try(:name),
          email: self.try(:email),
        })
      end if ENV['MIXPANEL_TOKEN'].present?
    end
  end
end
