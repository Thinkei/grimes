require 'grimes/config'
require 'grimes/rails_extension_extractor'
require 'grimes/message_bus/message_bus'

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
  end
end
