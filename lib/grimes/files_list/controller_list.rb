module FilesList
  class ControllerList
    attr_reader :rails_application

    def initialize(rails_application)
      @rails_application = rails_application
    end

    def get_controllers
      controllers = []
      if rails_application
        controllers = rails_application.routes.routes.map(&:app).map { |a| a.instance_variable_get(:@defaults) }.compact.sort_by { |a| a[:controller] }
      end
      controllers
    end
  end
end
