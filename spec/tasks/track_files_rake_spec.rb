require 'spec_helper'

describe 'grimes:track_files', type: :task do
  let(:rake_task_block) { double }
  let(:track_data) { { files_list: files_list } }

  it 'calls track block with the track files data' do
    Grimes.configure do |config|
      config.track_paths = []
      config.ignore_paths = []
      config.rake_task_block = rake_task_block
    end
    expect(rake_task_block).to receive(:call)
    subject.execute
  end

  context 'config track path' do
    let(:files_list) { 
      [
        "./spec/mock_track_files/white_list_files/white_list.text",
        "./spec/mock_track_files/ignore_files/ignore.text"
      ]
    }
    it 'tracks all file in track paths' do
      Grimes.configure do |config|
        config.track_paths = ['./spec/mock_track_files/**/*.*']
        config.ignore_paths = nil
        config.rake_task_block = rake_task_block
      end
      expect(rake_task_block).to receive(:call).with(track_data)
      subject.execute
    end
  end

  context 'config ignore_paths' do
    let(:files_list) { 
      [
        "./spec/mock_track_files/white_list_files/white_list.text",
      ]
    }
    it 'tracks all file in track paths' do
      Grimes.configure do |config|
        config.track_paths = ['./spec/mock_track_files/**/*.*']
        config.ignore_paths = ['./spec/mock_track_files/ignore_files/**/*.*']
        config.rake_task_block = rake_task_block
      end
      expect(rake_task_block).to receive(:call).with(track_data)
      subject.execute
    end
  end
end
