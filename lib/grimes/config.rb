module Grimes
  class Config
    attr_accessor :track_controller, :render_partial_block, :render_template_block,
                  :render_controller_block, :namespace, :rake_task_block, :bug_reporter,
                  :track_grape, :rails_application, :app_root
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
