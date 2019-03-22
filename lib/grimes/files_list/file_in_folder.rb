module FilesList
  class FileInFolder
    attr_reader :paths

    def initialize(paths)
      @paths = paths
    end

    def get_files
      paths.map { |path| Dir[path] }.flatten
    end
  end
end
