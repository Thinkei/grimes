module ActionView
  class LogSubscriber
    alias original_render_template render_template
    alias original_render_partial render_partial

    def render_template(event)
      begin
        template_file = from_rails_root(event.payload[:identifier])
        layout_file = from_rails_root(event.payload[:layout]) if event.payload[:layout]
        puts "Caught template: #{template_file}"
        puts "Caught layout: #{layout_file}" if layout_file
        original_render_template(event)
      rescue StandardError
        original_render_template(event)
      end
    end

    def render_partial(event)
      begin
        template_file = from_rails_root(event.payload[:identifier])
        layout_file = from_rails_root(event.payload[:layout]) if event.payload[:layout]
        puts "Caught partial template: #{template_file}"
        puts "Caught layout: #{layout_file}" if layout_file
        original_render_partial(event)
      rescue StandardError
        original_render_partial(event)
      end
    end
  end
end
