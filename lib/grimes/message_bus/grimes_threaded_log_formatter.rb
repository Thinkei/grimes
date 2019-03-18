module Grimes
  module MessageBus
    class GrimesThreadedLogFormatter < Logger::Formatter
      THREADED_FORMAT = "%s, [%s#%d Thread#%s] %s: %s\n".freeze
      def call(severity, time, progname, msg)
        THREADED_FORMAT % [
          severity,
          format_datetime(time), Process.pid, Thread.current.object_id,
          progname,
          msg2str(msg)
        ]
      end
    end
  end
end
