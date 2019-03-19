require 'spec_helper'
require 'grimes/files_list/file_in_folder'
require 'grimes/config'

describe FilesList::Coordinator do
  let(:config) do
    c = Grimes::Config.new
    c.track_paths = track_paths
    c.ignore_paths = ignore_paths
    c
  end
  let(:subject) { described_class.new(config) }

  context 'config track path' do
    let(:files_list) do
      [
        "./spec/mock_track_files/white_list_files/white_list.text",
        "./spec/mock_track_files/ignore_files/ignore.text"
      ].sort
    end
    let(:track_paths) { ['./spec/mock_track_files/**/*.*'] }
    let(:ignore_paths) { [] }
    it 'tracks all file in track paths' do
      expect(subject.files_list.sort).to eq(files_list)
    end
  end

  context 'config ignore_paths' do
    let(:files_list) do
      [
        "./spec/mock_track_files/white_list_files/white_list.text",
      ]
    end
    let(:track_paths) { ['./spec/mock_track_files/**/*.*'] }
    let(:ignore_paths) { ['./spec/mock_track_files/ignore_files/**/*.*'] }

    it 'tracks all file in track paths except ignore paths' do
      expect(subject.files_list.sort).to eq(files_list)
    end
  end
end
