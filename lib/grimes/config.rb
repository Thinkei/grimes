module Grimes
  class Config
    attr_accessor :bug_reporter

    def report_bug(error, params = {})
      bug_reporter.notify(error, params) if bug_reporter.present?
    end
  end
end
