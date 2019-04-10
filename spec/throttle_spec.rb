require 'spec_helper'

describe Grimes::Throttle do
  let(:time) { 1 }
  let(:track_log) { [] }
  let(:track_block) { -> (data) { track_log.push(data) } }

  it 'can start and call track_block every "time" second pass' do
    described_class.start(time, track_block)
    sleep 2
    expect(track_log.size).to eq(2)
  end
end
