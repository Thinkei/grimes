module Grimes
  module MessageBus
    class GrimesTopic
      def self.topics
        @topics ||= {}
      end

      def self.register(name, &resolver)
        topics[name] = resolver
      end

      def self.resolve(name, *args)
        raise "Grimes Topic resolver for #{name} not registered yet" unless topics[name]
        topics[name].call(*args)
      end
    end
  end
end
