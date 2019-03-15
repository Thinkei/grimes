require 'spec_helper'

describe Grimes do
  it 'has a version number' do
    expect(Grimes::VERSION).not_to be nil
  end

  describe '#configure' do
    let(:track_paths) { ['app/controller', 'app/model'] }
    let(:ignore_paths) { ['app/views/remove'] }
    before do
      Grimes.configure do |config|
        config.track_controller = true
        config.track_paths = track_paths
        config.ignore_paths = ignore_paths
      end
    end

    it 'stores config information' do
      config = Grimes.config
      expect(config.track_controller).to eq(true)
      expect(config.track_paths).to eq(track_paths)
      expect(config.ignore_paths).to eq(ignore_paths)
    end
  end
end
