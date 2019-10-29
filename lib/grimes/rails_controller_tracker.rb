module ActionController
  module Instrumentation
    alias original_process_action process_action
    # rubocop:disable Metrics/AbcSize
    def process_action(*args)
      begin
        raw_payload = {
          controller: self.class.name,
          action: self.action_name
        }
        controller_name = raw_payload[:controller]
        action_name = raw_payload[:action]
        file_path = ''
        controller_klass = Object.const_get(controller_name)
        if controller_klass.instance_methods.find_index(action_name.to_sym)
          path_location = controller_klass.instance_method(action_name.to_sym).source_location.first
          file_path = path_location.sub(Grimes.config.app_root, '')
        end

        callback_block = Grimes.config.render_controller_block
        callback_block&.call(controller_name: controller_name,
                             action_name: action_name,
                             file_path: file_path)
      rescue StandardError => error
        Grimes.config.report_bug(error)
        return original_process_action(*args)
      end
      original_process_action(*args)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
