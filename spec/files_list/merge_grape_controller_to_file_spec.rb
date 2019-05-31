require 'spec_helper'
require 'grimes/files_list/merge_grape_controller_to_file'

describe FilesList::MergeGrapeControllerToFile do
  let(:controllers) do
    [
      {:controller => "/code/app/controllers/model_1_controller.rb", :action => "action_1"},
      {:controller => "/code/app/controllers/model_1_controller.rb", :action => "action_2"},
      {:controller => "/code/app/controllers/model_2_controller.rb", :action => "action_3"},
    ]
  end
  let(:files) do
    [
      {:file_path => "app/controllers/model_1_controller.rb"},
      {:file_path => "app/controllers/model_2_controller.rb"},
      {:file_path => "app/controllers/model_3_controller.rb"},
    ]
  end
  let(:expected_result) do
    [
      {
        :file_path => "app/controllers/model_1_controller.rb",
        :extra => {
          controller: true,
          actions: ['action_1', 'action_2']
        }
      },
      {
        :file_path => "app/controllers/model_2_controller.rb",
        :extra => {
          controller: true,
          actions: ['action_3']
        }
      },
      { :file_path => "app/controllers/model_3_controller.rb" }
    ]
  end
  let(:subject) { described_class.new(controllers, files) }

  it 'merges controllers to files' do
    expect(subject.merge).to eq(expected_result)
  end
end
