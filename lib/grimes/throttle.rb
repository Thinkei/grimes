module Grimes
  class Throttle
    attr_reader :throttle_time, :track_block

    def initialize(throttle_time, track_block)
      # @queue = Queue.new
      @throttle_time = throttle_time
      @track_block = track_block
    end

    def start
      thread = Thread.new do
        p 'Start Grimes Tracking'
        loop do
          begin
            p 'Track block'
            track_data
            sleep throttle_time
          rescue StandardError => e
            Grimes.config.report_bug(error)
          end
        end
      end
      thread.abort_on_exception = true
    end

    def self.start(time, track_block)
      new(time, track_block).start
    end

    def self.track(path)
    end

    private

    def track_data
      begin
        track_block&.call(1)
      rescue StandardError => e
        Grimes.config.report_bug(error)
      end
    end
  end
end
