module Grimes::MessageBus::Messages
  class GrimesBase
    attr_reader :object, :event

    def initialize(object, event)
      @object = object
      @event = event
    end

    def message
      send("#{event}_message")
    end

    def partition_key
      object.uuid
    end
  end
end
