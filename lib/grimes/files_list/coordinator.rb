require 'grimes/files_list/file_in_folder'
require 'grimes/files_list/controller_list'
require 'grimes/files_list/merge_controller_to_file'

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
      if config.track_controller
        controllers = ControllerList.new(config.rails_application).get_controllers
        files_list = MergeControllerToFile.new(controllers, files_list).merge
      end
      files_list
    end
  end
end
