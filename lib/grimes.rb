require 'grimes/config'

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
