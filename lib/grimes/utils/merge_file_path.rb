module Utils
  class MergeFilePath
    def self.merge_paths(origin, paths)
      return origin unless paths
      new_value = paths.inject(origin) do |result, (key, value)|
        if result[key]
          path_count = value[:count] || 0
          result[key][:count] += path_count
        else
          result[key] = value
        end
        result
      end
      new_value
    end
  end
end
