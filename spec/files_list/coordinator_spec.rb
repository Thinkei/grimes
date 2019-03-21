require 'spec_helper'
require 'grimes/files_list/file_in_folder'
require 'grimes/files_list/merge_controller_to_file'
require 'grimes/files_list/merge_grape_controller_to_file'
require 'grimes/files_list/controller_list'
require 'grimes/files_list/grape_controller_list'
require 'grimes/config'

describe FilesList::Coordinator do
  let(:config) do
    c = Grimes::Config.new
    c.track_paths = track_paths
    c.ignore_paths = ignore_paths
    c
  end
  let(:subject) { described_class.new(config) }
  let(:track_paths) { ['./spec/mock_track_files/**/*.*'] }
  let(:ignore_paths) { [] }

  context 'config track path' do
    let(:files_list) do
      [
        { path: "./spec/mock_track_files/white_list_files/white_list.text" },
        { path: "./spec/mock_track_files/ignore_files/ignore.text" }
      ]
    end

    it 'tracks all file in track paths' do
      expect(subject.files_list).to match_array(files_list)
    end
  end

  context 'config ignore_paths' do
    let(:files_list) do
      [
        { path: "./spec/mock_track_files/white_list_files/white_list.text" },
      ]
    end
    let(:track_paths) { ['./spec/mock_track_files/**/*.*'] }
    let(:ignore_paths) { ['./spec/mock_track_files/ignore_files/**/*.*'] }

    it 'tracks all file in track paths except ignore paths' do
      expect(subject.files_list).to match_array(files_list)
    end
  end

  context 'config track controller is false' do
    let(:rails_application) { double }
    let(:config) do
      c = Grimes::Config.new
      c.track_paths = track_paths
      c.ignore_paths = ignore_paths
      c.track_controller = false
      c
    end
    let(:files_list) do
      [
        { path: "./spec/mock_track_files/white_list_files/white_list.text" },
        { path: "./spec/mock_track_files/ignore_files/ignore.text" }
      ]
    end

    it 'does not call MergeControllerToFile' do
      expect_any_instance_of(FilesList::MergeControllerToFile)
        .not_to receive(:merge)
      subject.files_list
    end
  end

  context 'config track controller is true' do
    let(:rails_application) { double }
    let(:config) do
      c = Grimes::Config.new
      c.track_paths = track_paths
      c.ignore_paths = ignore_paths
      c.track_controller = true
      c.rails_application = rails_application
      c
    end
    let(:files_list) do
      [
        { path: "./spec/mock_track_files/white_list_files/white_list.text" },
        { path: "./spec/mock_track_files/ignore_files/ignore.text" }
      ]
    end

    let(:controllers) { [] }
    let(:merge_results) { double } 
    let(:controller_list_service) { double }
    let(:merge_service) { double }

    before do
      allow_any_instance_of(FilesList::ControllerList)
        .to receive(:get_controllers).and_return(controllers)
      allow_any_instance_of(FilesList::GrapeControllerList)
        .to receive(:get_controllers).and_return(controllers)
      allow_any_instance_of(FilesList::MergeControllerToFile)
        .to receive(:merge).and_return(merge_results)
      allow_any_instance_of(FilesList::MergeGrapeControllerToFile)
        .to receive(:merge).and_return(merge_results)
      allow(merge_service).to receive(:merge).and_return(merge_results)
    end

    it 'calls ControllerList to get the controller list' do
      expect(FilesList::ControllerList).to receive(:new).with(rails_application)
        .and_return(controller_list_service)
      expect(controller_list_service).to receive(:get_controllers)
        .and_return(controllers)
      subject.files_list
    end

    it 'calls MergeControllerToFile with correct values' do
      expect(FilesList::MergeControllerToFile).to receive(:new)
        .with(controllers, files_list)
        .and_return(merge_service)
      expect(subject.files_list).to equal(merge_results)
    end

    it 'calls MergeControllerToFile with correct values' do
      expect(FilesList::MergeGrapeControllerToFile).to receive(:new)
        .with(controllers, merge_results)
        .and_return(merge_service)
      expect(subject.files_list).to equal(merge_results)
    end
  end
end
