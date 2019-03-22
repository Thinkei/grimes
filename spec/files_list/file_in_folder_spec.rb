require 'spec_helper'
require 'grimes/files_list/file_in_folder'

describe FilesList::FileInFolder do
  let(:files_list) do
    [
      "./spec/mock_track_files/white_list_files/white_list.text",
      "./spec/mock_track_files/ignore_files/ignore.text"
    ].sort
  end
  let(:paths) { ['./spec/mock_track_files/**/*.*'] }

  it 'gets all files in white list paths' do
    expect(described_class.new(paths).get_files).to match_array(files_list)
  end
end
