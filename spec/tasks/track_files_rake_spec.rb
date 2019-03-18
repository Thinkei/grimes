require 'spec_helper'

describe 'grimes:track_files', type: :task do

  it 'calls track block with the track files data' do
    subject.execute
  end
end
