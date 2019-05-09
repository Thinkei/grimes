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
            p e
            Grimes.config.report_bug(e)
          end
        end
      end
      thread.abort_on_exception = true
    end

    def track(path, extra_data)
      mutex.synchronize do
        @all_paths[path] ||= { count: 0 }
        if @all_paths[path][:count] == 0 && !extra_data.empty?
          @all_paths[path][:extra_data] = extra_data
        end
        @all_paths[path][:count] += 1
      end
    end

    def self.start(time, track_block)
      @instance = new(time, track_block)
      @instance.start
    end

    def self.track(path, extra_data = {})
      @instance.track(path, extra_data)
    end

    def self.flush_buffer
      @instance.track_data
    end

    def track_data
      begin
        track_block&.call(@all_paths)
        mutex.synchronize do
          @all_paths = {}
        end
      rescue StandardError => e
        Grimes.config.report_bug(e)
      end
    end
  end
end
