require 'spec_helper'
require 'grimes/utils/merge_file_path'

describe Utils::MergeFilePath do
  let(:list) do
    [
      { file_path: { count: 3 } },
      { file_path_2: { count: 3 } },
      { file_path: { count: 1 } },
      {}
    ]
  end

  let(:expected_result) do
    {
      file_path: { count: 4 },
      file_path_2: { count: 3 }
    }
  end
  it 'merges correctly' do
    result = list.inject({}) do |rs, value|
      described_class.merge_paths(rs, value)
    end
    expect(result).to eq(expected_result)
  end
end
