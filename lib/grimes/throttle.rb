require 'thread'

module Grimes
  class Throttle
    attr_reader :throttle_time, :track_block, :all_paths, :mutex

    def initialize(throttle_time, track_block)
      @throttle_time = throttle_time
      @track_block = track_block
      @all_paths = {}
      @mutex = Mutex.new
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

    def track(path)
      mutex.synchronize do
        all_paths[path] ||= 0
        all_paths[path] += 1
      end
    end

    def self.start(time, track_block)
      @@instance = new(time, track_block)
      @@instance.start
    end

    def self.track(path)
      @@instance.track(path)
    end

    private

    def track_data
      begin
        track_block&.call(all_paths)
        mutex.synchronize do
          @all_paths = Hash.new(0)
        end
      rescue StandardError => e
        Grimes.config.report_bug(error)
      end
    end
  end
end
