require 'grimes/config'
require 'grimes/railtie' if defined?(Rails)
require 'grimes/rails_extension_extractor'
require 'grimes/message_bus/message_bus'
require 'grimes/grape_tracking_middleware'

module Grimes
  class << self
    def configure
      yield(config)
    end

    def config
      @config ||= Config.new
    end

    def track_rails_templates
      require 'grimes/rails_template_tracker'
    end

    def track_rails_controllers
      require 'grimes/rails_controller_tracker'
    end
  end
end
