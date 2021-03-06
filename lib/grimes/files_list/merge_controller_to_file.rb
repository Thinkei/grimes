module FilesList
  class MergeControllerToFile
    attr_reader :controllers, :files
    def initialize(controllers, files)
      @controllers = controllers
      @files = files
    end

    def merge
      files.map do |file|
        controller = find_controller_for_file(file)
        if controller
          file = file.merge({
            extra: {
              controller: true,
              actions: controller[:actions]
            }
          })
        end
        file
      end
    end

    private

    def grouped_controllers
      @grouped_controllers ||= begin
         results = []
         controllers.each do |controller|
           target_controller = find_controller(results, controller)
           if !target_controller
             target_controller = default_controller(controller[:controller])
             results.push(target_controller)
           end
           target_controller[:actions] << controller[:action]
         end
         results
       end
    end

    def find_controller(controllers, controller)
      find_controller = controllers.find { |c| c[:controller] == controller[:controller] }
      find_controller
    end

    def default_controller(controller_path)
      { controller: controller_path, actions: [] }
    end

    def find_controller_for_file(file)
      grouped_controllers.find do |controller|
        controller_path = "controllers/#{controller[:controller]}_controller"
        file[:file_path].include?(controller_path)
      end
    end
  end
end
