module Grimes
  class Config
    attr_accessor :track_controller, :track_paths, :ignore_paths,
        :render_partial_block, :render_template_block, :namespace,
        :rake_task_block
  end
end
