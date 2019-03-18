require 'spec_helper'

describe Grimes do
  it 'has a version number' do
    expect(Grimes::VERSION).not_to be nil
  end

  describe '#configure' do
    let(:track_paths) { ['app/controller', 'app/model'] }
    let(:ignore_paths) { ['app/views/remove'] }
    let(:mock_render_template_logic) { double }
    let(:mock_render_partial_logic) { double }
    before do
      Grimes.configure do |config|
        config.track_controller = true
        config.track_paths = track_paths
        config.ignore_paths = ignore_paths
        config.namespace = 'mainapp'
      end
    end

    it 'stores config information' do
      config = Grimes.config
      expect(config.track_controller).to eq(true)
      expect(config.track_paths).to eq(track_paths)
      expect(config.ignore_paths).to eq(ignore_paths)
      expect(config.namespace).to eq('mainapp')
    end

    it 'stores on_render_template and on_render_partial' do
      Grimes.configure do |config|
        config.render_template_block = -> (template, layout) { mock_render_template_logic.call  }
        config.render_partial_block = -> (template, layout) { mock_render_partial_logic.call }
      end

      expect(Grimes.config.render_partial_block).not_to be_nil
      expect(mock_render_partial_logic).to receive(:call)
      Grimes.config.render_partial_block.call(1, 2)
    end
  end
end
