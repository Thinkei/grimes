module Grimes
  class GrapeTrackingMiddleware < Grape::Middleware::Base
    def before
      route = self.env["api.endpoint"].routes.first
      action = "#{route.request_method} #{route.path}"
      source_location = route.app.source.source_location.first
      callback_block = Grimes.config.call_grape_controller_block
      callback_block && callback_block.call({ path: source_location, action: action })
    rescue
    end
  end
end
