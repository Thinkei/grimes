require 'grape'

module Grimes
  class GrapeTrackingMiddleware < Grape::Middleware::Base
    def before
      route = self.env["api.endpoint"].routes.first
      action = get_controller_action(route)
      source_location = get_controller_file_location(route).sub(Grimes.config.app_root, '')
      callback_block = Grimes.config.call_grape_controller_block
      callback_block&.call({ file_path: source_location, action_name: action })
    rescue StandardError => e
      p e.inspect
    end

    private

    def get_controller_action(route)
      "#{route.request_method} #{route.path}"
    end

    def get_controller_file_location(route)
      route.app.source.source_location.first
    end
  end
end
