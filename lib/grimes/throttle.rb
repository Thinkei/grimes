require 'grimes/utils/merge_file_path'

module Grimes
  class Throttle
    attr_reader :throttle_time, :track_block, :thread, :limit

    def initialize(throttle_time, track_block, limit)
      @throttle_time = throttle_time
      @track_block = track_block
      @limit = limit
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

    def self.start(time, track_block, limit = 10000)
      @instance = new(time, track_block, limit)
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
        parts_num = [(result.size/limit.to_f).ceil, 1].max
        split_into(result, parts_num).each do |part|
          track_block&.call(part)
        end
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
        # prevent the case some thread change grimes_all_paths durring our loop
        paths = thread[:grimes_all_paths]&.dup
        all_paths = Utils::MergeFilePath.merge_paths(all_paths, paths)
      end
      all_paths
    end

    private
    def split_into(hash, divisions)
      count = 0
      result = hash.inject([]) do |final, key_value|
        final[count%divisions] ||= {}
        final[count%divisions][key_value[0]] = key_value[1]
        count += 1
        final
      end
      result
    end
  end
end
