require 'spec_helper'
require 'grimes/files_list/grape_controller_list'

describe FilesList::GrapeControllerList do
  let(:route) { double }
  let(:controller_list) do 
    [
      OpenStruct.new({
        app: OpenStruct.new({
          source: OpenStruct.new({ source_location: ['location_1'] })
        }),
        request_method: 'GET',
        path: 'action 1'
      }),
      OpenStruct.new({
        app: OpenStruct.new({
          source: OpenStruct.new({ source_location: ['location_2']})
        }),
        request_method: 'DELETE',
        path: 'action 1'
      }),
    ]
  end

  let(:result_controller_list) do 
    [
      { controller: 'location_1', action: 'GET action 1' },
      { controller: 'location_2', action: 'DELETE action 1' }
    ]
  end

  before do
    allow(route).to receive(:routes).and_return(controller_list)
  end

  it 'returns controller list' do
    expect(described_class.new([route]).get_controllers).to match_array(result_controller_list)
  end
end
