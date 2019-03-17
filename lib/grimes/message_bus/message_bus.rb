require 'grimes/message_bus/buses/grimes_base'
require 'grimes/message_bus/messages/grimes_base'
require 'grimes/message_bus/publishers/grimes_kafka_adapter'
require 'grimes/message_bus/publishers/grimes_mock_adapter'
require 'grimes/message_bus/grimes_control'
require 'grimes/message_bus/grimes_topic'

module Grimes
  module MessageBus
    MESSAGE_BUS_PUBLISHER_ADAPTER_KEY = 'MESSAGE_BUS_PUBLISHER_ADAPTER'.freeze

    def self.default_publisher_adapter
      if ENV[MESSAGE_BUS_PUBLISHER_ADAPTER_KEY]
        Object.const_get(ENV[MESSAGE_BUS_PUBLISHER_ADAPTER_KEY])
      else
        Publishers::GrimesMockAdapter
      end
    end
  end
end
