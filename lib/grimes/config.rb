module Grimes
  class Config
    attr_accessor :track_controller, :render_partial_block, :render_template_block,
      :namespace, :rake_task_block, :bug_reporter
    attr_writer :track_paths, :ignore_paths

    def track_paths
      @track_paths || ['./**/*.*']
    end

    def ignore_paths
      @ignore_paths || []
    end

    def report_bug(error, params = {})
      bug_reporter.notify(error, params) if bug_reporter.present?
    end
  end
end
