require 'spec_helper'

describe 'grimes:track_files', type: :task do
  let(:rake_task_block) { double }
  let(:track_data) { [ 'list' ] }

  it 'calls track block with the track files data' do
    Grimes.configure do |config|
      config.track_paths = []
      config.ignore_paths = []
      config.rake_task_block = rake_task_block
    end
    expect(rake_task_block).to receive(:call)
    subject.execute
  end

  it 'calls FilesList::Coordinator to get files list' do
    Grimes.configure do |config|
      config.rake_task_block = rake_task_block
    end
    expect(rake_task_block).to receive(:call).with(track_data)
    expect_any_instance_of(FilesList::Coordinator).to receive(:files_list)
      .and_return(track_data)
    subject.execute
  end
end
