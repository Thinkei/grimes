module ActionController
  class LogSubscriber
    alias original_process_action process_action

    def process_action(event)
      begin
        payload = event.payload
        controller_name = payload[:controller]
        action_name = payload[:action]

        path_location = Object.const_get(controller_name).instance_method(action_name.to_sym).source_location.first
        file_path = path_location.sub(Grimes.config.app_root, '')
        callback_block = Grimes.config.render_controller_block
        callback_block&.call(controller_name: controller_name, action_name: action_name, file_path: file_path)
        original_process_action(event)
      rescue StandardError => error
        puts error.message
        Grimes.config.report_bug(error)
        original_process_action(event)
      end
    end
  end
end
