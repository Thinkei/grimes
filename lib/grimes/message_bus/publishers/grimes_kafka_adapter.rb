module Grimes::MessageBus::Publishers
  class GrimesKafkaAdapter
    CLIENT_ID = 'EmploymentHero'.freeze
    DELIVERY_THRESHOLD = 500
    DELIVERY_INTERVAL = 0.5
    DELIVERY_MINIMUM = 1
    RETRY_DELAY = 3
    STOP_THRESHOLD = 15

    attr_reader :client, :producer, :logger

    def initialize(kafka_klass: ::Kafka, logger: nil)
      @command_queue = Queue.new

      @client = kafka_klass.new(kafka_client_info)
      @producer = @client.producer(max_buffer_size: DELIVERY_THRESHOLD)
      @logger = logger

      @started = false
      @start_thread_lock = Mutex.new
      @buffer = []
      @buffer_lock = Mutex.new
      @last_published_at = Time.now
    end

    def start
      @start_thread_lock.synchronize do
        if !started? || !@publish_thread&.alive?
          start_publish_thread
          start_timer
          @started = true
        end
      end
    end

    def started?
      @started == true
    end

    def stop(wait_until_finish = true)
      return unless started?

      if wait_until_finish
        count = 0
        loop do
          sleep 1
          count += 1
          break if free? || count > STOP_THRESHOLD
        end
      end

      @command_queue.push(nil)

      @start_thread_lock.synchronize do
        @producer.shutdown
        @publish_thread&.kill
        @timer_thread&.kill
      end
      logger.info("Message bus gracefully shutdowns. Have a good day!")
      @started = false
    end

    # Typical package format:
    # {
    #   topic: 'ATopic',
    #   message: 'Hello',
    #   partition_key: 'partition_key'
    # }
    def publish(package)
      lock_buffer { |buffer| buffer << package }
      @command_queue.push(:deliver)
    end

    def free?
      lock_buffer(&:empty?)
    end

    private

    def start_timer
      @timer_thread = Thread.new do
        begin
          logger.info("Message bus's Kafka timer thread started")
          loop do
            sleep DELIVERY_INTERVAL
            @command_queue.push(:deliver)
          end
        rescue StandardError => e
          handle_publish_exception(e)
          retry
        end
      end
      @timer_thread.abort_on_exception = true
    end

    def start_publish_thread
      @publish_thread = Thread.new do
        begin
          logger.info("Message bus's Kafka publish thread started")
          loop do
            command = @command_queue.pop
            if command.nil?
              logger.info("Message bus publishing thread stopped")
              break
            else
              deliver_packages
            end
          end
        rescue StandardError => e
          handle_publish_exception(e)
          retry
        end
      end
      @publish_thread.abort_on_exception = true
    end

    def deliver_packages
      if @last_published_at + DELIVERY_INTERVAL < Time.now ||
          @buffer.size >= DELIVERY_THRESHOLD
        deliver_packages_with_retry
        @last_published_at = Time.now
      end
    end

    def deliver_packages_with_retry
      deliver_batch_count = [@buffer.size, DELIVERY_THRESHOLD].min
      return unless deliver_batch_count.positive?

      begin
        @logger.info("Message bus is delivering a batch of #{deliver_batch_count} packages.")

        deliver_batch = lock_buffer { |buffer| buffer.first(deliver_batch_count) }
        @producer.clear_buffer
        deliver_batch.each do |package|
          options = build_options(package)
          @producer.produce(package[:message], options)
        end
        @producer.deliver_messages
        lock_buffer { |buffer| buffer.shift(deliver_batch_count) }
      rescue Kafka::MessageSizeTooLarge, Kafka::BufferOverflow
        deliver_batch_count /= 2
        if deliver_batch_count < DELIVERY_MINIMUM
          @logger.error('Sorry mate! No luck with the message size. Stripping the message!')
          Grimes.config.report_bug(
            StandardError.new("Message bus's packages are too big!"),
            packages: deliver_batch
          )
          lock_buffer(&:shift)
        else
          @logger.warn("Message bus's batch is too big. Retrying with smaller size.")
          retry
        end
      end
    end

    def handle_publish_exception(exception)
      @logger.error(exception.message)
      Grimes.config.report_bug(exception)
      sleep RETRY_DELAY
    end

    def lock_buffer
      return unless block_given?
      @buffer_lock.synchronize do
        yield @buffer
      end
    end

    def build_options(package)
      options = {
        topic: package[:topic]
      }
      options[:partition_key] = package[:partition_key].to_s if package.key?(:partition_key)
      options
    end

    def kafka_client_info
      info = {
        seed_brokers: ENV['KAFKA_BROKERS'].to_s.split(','),
        client_id: CLIENT_ID,
        logger: @logger
      }
      if ENV['KAFKA_CA']
        info.merge!(
          ssl_ca_cert: ENV['KAFKA_CA'],
          ssl_client_cert: ENV['KAFKA_CERT'],
          ssl_client_cert_key: ENV['KAFKA_CERT_KEY']
        )
      elsif ENV['KAFKA_CA_FILE']
        info = info.merge(
          ssl_ca_cert: File.read(ENV['KAFKA_CA_FILE']),
          ssl_client_cert: File.read(ENV['KAFKA_CERT_FILE']),
          ssl_client_cert_key: File.read(ENV['KAFKA_CERT_KEY_FILE'])
        )
      end
      info
    end
  end
end
