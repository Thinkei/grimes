module Grimes
  class Config
    attr_accessor :track_controller, :track_paths, :ignore_paths,
        :on_render_partial, :on_render_template, :namespace
  end
end
