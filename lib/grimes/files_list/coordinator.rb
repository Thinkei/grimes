require 'grimes/files_list/file_in_folder'

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
    # controllers = []
    # if Rails.application
    #   controllers = Rails.application.routes.routes.map(&:app).map { |a| a.instance_variable_get(:@defaults) }.compact.sort_by { |a| a[:controller] }
    # end
    # track_data = {
    #   files_list: files_list.sort,
    #   controllers: controllers
    # }
    end
  end
end
