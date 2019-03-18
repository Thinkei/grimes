module ActionView
  class LogSubscriber
    alias original_render_template render_template
    alias original_render_partial render_partial

    def render_template(event)
      begin
        template_file = event.payload[:identifier].sub(rails_root, EMPTY)
        extension = Grimes::RailsExtensionExtractor.new(template_file).extract
        layout_file = nil
        if event.payload[:layout]
          layout_file = event.payload[:layout]
          layout_file = "app/views/#{layout_file}#{extension}"
        end
        puts "Caught template: #{template_file}"
        puts "Caught layout: #{layout_file}" if layout_file
        original_render_template(event)
      rescue StandardError
        original_render_template(event)
      end
    end

    def render_partial(event)
      begin
        template_file = event.payload[:identifier].sub(rails_root, EMPTY)
        extension = Grimes::RailsExtensionExtractor.new(template_file).extract
        layout_file = nil
        if event.payload[:layout]
          layout_file = event.payload[:layout]
          layout_file = "app/views/#{layout_file}#{extension}"
        end
        puts "Caught partial template: #{template_file}"
        puts "Caught layout: #{layout_file}" if layout_file
        original_render_partial(event)
      rescue StandardError
        original_render_partial(event)
      end
    end
  end
end
