module Grimes
  class Throttle
    attr_reader :throttle_time, :track_block

    def initialize(throttle_time, track_block)
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
            p e
            Grimes.config.report_bug(e)
          end
        end
      end
      thread.abort_on_exception = true
    end

    def track(path, extra_data)
      all_paths = Thread.current[:grimes_all_paths] || {}
      all_paths[path] ||= { count: 0 }
      if all_paths[path][:count] == 0 && !extra_data.empty?
        all_paths[path][:extra_data] = extra_data
      end
      all_paths[path][:count] += 1
      Thread.current[:grimes_all_paths] = all_paths
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
        result = calculate_all_paths_from_threads
        track_block&.call(result)
        reset_all_paths
      rescue StandardError => e
        p e
        Grimes.config.report_bug(e)
      end
    end

    def reset_all_paths
      Thread.list.each do |thread|
        thread[:grimes_all_paths] = {}
      end
    end

    def calculate_all_paths_from_threads
      all_paths = {}
      Thread.list.each do |thread|
        paths = thread[:grimes_all_paths]
        all_paths = merge_paths(all_paths, paths)
      end
      all_paths
    end

    def merge_paths(origin, paths)
      return origin unless paths
      new_value = paths.inject(origin) do |result, (key, value)|
        if result[key]
          path_count = value[:count] || 0
          result[key][:count] += path_count
        else
          result[key] = value
        end
        result
      end
      new_value
    end
  end
end
