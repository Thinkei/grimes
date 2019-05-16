module Grimes
  class LogFormatter
    EVENT_TYPES = [
      TRACKING_EVENT = 'tracking_event',
      FILE_LIST_EVENT = 'file_list_event'
    ]
    def self.format_tracking_data(data)
      format_data(data, TRACKING_EVENT)
    end

    def self.format_file_list_data(data)
      format_data(data, FILE_LIST_EVENT)
    end

    def self.grape_controller_path(data)
      path = "#{relative_path(data[:path])} #{data[:action]}"
      path
    end

    def self.controller_path(data)
      path = data[:file_path] + data[:controller_name] + data[:action_name]
      path
    end

    def self.view_path(data)
      path = data[:file_path]
      path
    end

    def self.relative_path(path)
      file_path = path.sub(Grimes.config.app_root, '')
    end

    private

    def self.format_data(data, event_type)
      {
        dead_code_tracking: true,
        type: event_type,
        service: Grimes.config.namespace,
        data: data,
      }.to_json
    end
  end
end
