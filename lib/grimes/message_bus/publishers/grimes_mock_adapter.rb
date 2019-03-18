# Used for test only. This adapter is not thread-safe
module Grimes::MessageBus::Publishers
  class GrimesMockAdapter
    def self.published_messages
      @published_messages ||= []
    end

    def self.clear_published_messages
      @published_messages = []
    end

    def initialize(logger: nil)
      @logger = logger
    end

    def publish(package)
      @logger.debug("MessageBus#publish") { package.to_s }
      self.class.published_messages << package
    end

    def start
      @started = true
    end

    def started?
      @started
    end

    def stop
      @started = false
    end

    def free?
      self.class.published_messages.empty?
    end
  end
end
