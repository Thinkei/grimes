require 'grimes/files_list/file_in_folder'
require 'grimes/files_list/controller_list'
require 'grimes/files_list/grape_controller_list'
require 'grimes/files_list/merge_controller_to_file'
require 'grimes/files_list/merge_grape_controller_to_file'

module FilesList
  class Coordinator
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def files_list
      white_list_files = FileInFolder.new(config.track_paths).get_files
      ignore_files = FileInFolder.new(config.ignore_paths).get_files
      files_list = white_list_files - ignore_files
      files_list = files_list.map { |file| { path: file } }
      files_list = merge_controllers(files_list) if config.track_controller
      files_list
    end

    private

    def merge_controllers(files_list)
      controllers = ControllerList.new(config.rails_application).get_controllers
      grape_controllers = GrapeControllerList.new(config.grape_routes).get_controllers
      new_files_list = MergeControllerToFile.new(controllers, files_list).merge
      new_files_list = MergeGrapeControllerToFile.new(grape_controllers, new_files_list).merge
      new_files_list
    end
  end
end
