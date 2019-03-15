require 'grimes/version'
require 'grimes/config'
require 'grimes/railtie' if defined?(Rails)

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
