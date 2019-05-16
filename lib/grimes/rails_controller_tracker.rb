module ActionController
  module Instrumentation
    alias original_process_action process_action
    # rubocop:disable Metrics/AbcSize
    def process_action(*args)
      raw_payload = {
        controller: self.class.name,
        action: self.action_name
      }
      controller_name = raw_payload[:controller]
      action_name = raw_payload[:action]
      path_location = Object.const_get(controller_name).instance_method(action_name.to_sym).source_location.first
      file_path = path_location.sub(Grimes.config.app_root, '')
      callback_block = Grimes.config.render_controller_block
      callback_block&.call(controller_name: controller_name,
                           action_name: action_name,
                           file_path: file_path)
      original_process_action(*args)
    rescue StandardError => error
      Grimes.config.report_bug(error)
      original_process_action(*args)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
