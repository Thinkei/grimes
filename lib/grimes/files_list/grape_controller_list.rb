# This logic is tight coupling with Grape API, please check the Grape API more details

module FilesList
  class GrapeControllerList
    attr_reader :grape_routes

    def initialize(grape_routes)
      @grape_routes = grape_routes
    end

    def get_controllers
      grape_routes.map { |route|
        route.routes
          .map do |r|
            {
              controller: r.app.source.source_location.first,
              action: "#{r.request_method} #{r.path}"
            }
        end
      }.flatten
    end
  end
end
