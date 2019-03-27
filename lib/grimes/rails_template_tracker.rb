module ActionView
  class LogSubscriber
    alias original_render_template render_template
    alias original_render_partial render_partial

    def render_template(event)
      begin
        template_file = event.payload[:identifier].sub(rails_root, EMPTY)
        callback_block = Grimes.config.render_template_block
        callback_block&.call(file_path: template_file)
        original_render_template(event)
      rescue StandardError => error
        Grimes.config.report_bug(error)
        original_render_template(event)
      end
    end

    def render_partial(event)
      begin
        template_file = event.payload[:identifier].sub(rails_root, EMPTY)
        callback_block = Grimes.config.render_partial_block
        callback_block&.call(file: template_file)
        original_render_partial(event)
      rescue StandardError => error
        Grimes.config.report_bug(error)
        original_render_partial(event)
      end
    end
  end

  class TemplateRenderer
    alias original_find_layout find_layout

    private

    def find_layout(layout, keys)
      begin
        layout = with_layout_format { resolve_layout(layout, keys) }
        callback_block = Grimes.config.render_template_block
        callback_block&.call(file: layout.inspect)
        layout
      rescue StandardError => error
        Grimes.config.report_bug(error)
        original_find_layout(layout, keys)
      end
    end
  end
end

