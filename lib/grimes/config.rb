module Grimes
  class Config
    attr_accessor :track_controller, :namespace, :bug_reporter, :rails_application, :app_root,
      :rake_task_block, 
      :call_grape_controller_block,
      :render_controller_block,
      :render_partial_block,
      :render_template_block

    attr_writer :track_paths, :ignore_paths, :grape_routes

    def track_paths
      @track_paths || ['./**/*.*']
    end

    def ignore_paths
      @ignore_paths || []
    end

    def grape_routes
      @grape_routes || []
    end

    def report_bug(error, params = {})
      bug_reporter.notify(error, params) if bug_reporter.present?
    end
  end
end
