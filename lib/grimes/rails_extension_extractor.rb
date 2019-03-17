module Grimes
  class RailsExtensionExtractor
    TEMPLATE_PATH_REGEX = /(?<extension>((\.\S+)+))/

    def initialize(layout_path)
      @path = layout_path
    end

    def extract
      @path.match(TEMPLATE_PATH_REGEX)[:extension]
    end
  end
end
