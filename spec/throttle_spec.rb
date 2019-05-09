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

  it 'track path info and call track_block with that data' do
    described_class.start(time, track_block)
    described_class.track('file_path')
    sleep 2
    expect(track_log[0]).to eq({ 'file_path' => { count: 1 } })
  end

  it 'works fine with tracking thousands times' do
    described_class.start(time, track_block)
    1000000.times.each { described_class.track("file_path_#{Time.now.usec/100}") }
    expect(track_log.size >= 1).to be_truthy
  end

  it 'reset track data after call track data' do
    sleep 1
    described_class.start(time, track_block)
    described_class.track('file_path')
    sleep 1
    described_class.track('file_path')
    sleep 1
    expect(track_log[0]).to eq({ 'file_path' => { count: 1 } })
    expect(track_log[1]).to eq({ 'file_path' => { count: 1 } })
  end

  it 'works in many thread case' do
    described_class.start(time, track_block)
    threads = (1..3).map do
      Thread.new do
        described_class.track('file_path')
        # Sleep to keep the thread alive until we run the collect data method.
        # On prod, the thread will keep alive in thread poll so don't worry about it
        sleep 2
      end
    end
    sleep 1
    expect(track_log[0]).to eq({ 'file_path' => { count: 3 } })
  end

  it 'keeps extra data' do
    described_class.start(time, track_block)
    described_class.track('file_path', { data: 1 })
    sleep 1
    expect(track_log[0]).to eq({ 'file_path' => { count: 1, extra_data: { data: 1 }} })
  end
end
