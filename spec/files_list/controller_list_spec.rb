require 'spec_helper'
require 'grimes/files_list/controller_list'

describe FilesList::ControllerList do
  let(:application) { double }
  let(:controller_list) do 
    [
      nil,
      { controller: 2, action: 'action 2' },
      { controller: 1, action: 'action 1' }
    ]
  end

  let(:result_controller_list) do 
    [
      { controller: 2, action: 'action 2' },
      { controller: 1, action: 'action 1' }
    ]
  end

  before do
    allow(application).to receive_message_chain(
      :routes, :routes, :map, :map) { controller_list }
  end

  it 'returns controller list' do
    expect(described_class.new(application).get_controllers).to match_array(result_controller_list)
  end
end
