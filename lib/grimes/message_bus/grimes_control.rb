module Grimes
  module MessageBus
    class GrimesControl
      RETRY_DELAY = 5
      class << self
        attr_accessor :instance

        def init(*buses)
          MessageBus::GrimesControl.new(*buses).start
        end
      end

      attr_reader :packages, :buses, :publisher, :logger

      def start
        buses.map(&:enable)
      end

      def stop
        logger.info("Grimes Message bus is stopping")
        logger.info("Grimes Message bus is delivering the rest packages")

        publisher&.stop
        buses.map(&:disable)
      end

      def async_publish(package)
        raise 'Grimes Topic is missing' if package[:topic].blank?
        raise 'Grimes Message is missing' if package[:message].blank?

        publisher.start
        publisher.publish(package)
      end

      private

      def initialize(*buses)
        raise 'Only one instance of MessageBus::GrimesControl allowed' if self.class.instance

        @logger = Logger.new(STDOUT).tap do |logger|
          logger.level = (ENV['LOG_LEVEL'] || Logger::INFO).to_i
          logger.formatter = GrimesThreadedLogFormatter.new
        end
        @buses = buses

        @publisher = MessageBus.default_publisher_adapter.new(logger: logger)

        self.class.instance = self
      end
    end
  end
end
