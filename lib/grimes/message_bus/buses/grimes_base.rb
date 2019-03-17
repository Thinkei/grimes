module Grimes
  module MessageBus
    module Buses
      class GrimesBase
        class << self
          attr_accessor :bus_name, :bus_destroy_name

          def enabled?
            @enabled
          end

          def disable
            @enabled = false
          end

          def enable
            return if @enabled
            @enabled = true
          end
        end

        def initialize(event: nil, decorator: nil)
          @event = event
          @decorator = decorator
        end

        def async_publish(object, event: nil, decorator: nil)
          raise 'Message bus control has not started' unless MessageBus::GrimesControl.instance

          chosen_decorator = decorator || @decorator
          chosen_event = event || @event

          raise 'Event is missing' if chosen_event.blank?
          raise 'Decorator is missing' if chosen_decorator.blank?

          topic = MessageBus::GrimesTopic.resolve(self.class.bus_name, object)
          decorator_instance = chosen_decorator.new(object, chosen_event)
          MessageBus::GrimesControl.instance.async_publish(
            message: decorator_instance.message.to_json,
            topic: topic,
            partition_key: decorator_instance.partition_key
          )
        end
      end
    end
  end
end
