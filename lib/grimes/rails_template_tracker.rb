module ActionView
  class TemplateRenderer
    alias original_render_template render_template

    private

    def render_template(template, layout_name = nil, locals = nil)
      begin
        template_path = template.identifier.sub(Grimes.config.app_root, '')
        callback_block = Grimes.config.render_template_block
        callback_block&.call(file_path: template_path)
        original_render_template(template, layout_name, locals)
      rescue StandardError => error
        Grimes.config.report_bug(error)
        original_render_template(template, layout_name, locals)
      end
    end

    def find_layout(layout, keys)
      begin
        layout = with_layout_format { resolve_layout(layout, keys) }
        callback_block = Grimes.config.render_template_block
        callback_block&.call(file_path: layout.inspect)
        layout
      rescue StandardError => error
        Grimes.config.report_bug(error)
        original_find_layout(layout, keys)
      end
    end
  end

  class PartialRenderer
    alias original_render render

    def render(context, options, block)
      result = original_render(context, options, block)
      identifier = (@template = find_partial) ? @template.identifier : @path
      template_path = identifier.sub(Grimes.config.app_root, '')
      callback_block = Grimes.config.render_partial_block
      callback_block&.call(file_path: template_path)
      result
    rescue StandardError => error
      Grimes.config.report_bug(error)
      original_render(context, options, block)
    end
  end
end

