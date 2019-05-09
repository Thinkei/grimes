require 'spec_helper'

describe Grimes::Throttle do
  let(:time) { 0.1 }
  let!(:track_log) { [] }
  let(:track_block) { -> (data) { track_log.push(data) } }

  before do
    Thread.list.each do |thread|
      Thread.kill(thread) if thread != Thread.current
    end
  end

  after { described_class.flush_buffer }

  it 'can start and call track_block every "time" second pass' do
    described_class.start(time, track_block)
    sleep 0.2
    expect(track_log.size >= 2).to be_truthy
  end

  it 'track path info and call track_block with that data' do
    described_class.start(time, track_block)
    described_class.track('file_path')
    sleep 0.2
    log_result = track_log.inject({}) do |rs, value|
      Utils::MergeFilePath.merge_paths(rs, value)
    end
    expect(log_result).to eq({ 'file_path' => { count: 1 } })
  end

  it 'works fine with tracking thousands times' do
    described_class.start(time, track_block)
    1000000.times.each { described_class.track("file_path_#{Time.now.usec/100}") }
    expect(track_log.size >= 1).to be_truthy
  end

  it 'reset track data after call track data' do
    described_class.start(time, track_block)
    described_class.track('file_path')
    sleep 0.1
    described_class.track('file_path')
    sleep 0.3
    expect(track_log.compact[0]).to eq({ 'file_path' => { count: 1 } })
    expect(track_log.compact[1]).to eq({ 'file_path' => { count: 1 } })
  end

  it 'works in many thread case' do
    described_class.start(time, track_block)
    threads = (1..3).map do |i|
      Thread.new do
        sleep 0.2 if i == 2
        described_class.track('file_path')
        # Sleep to keep the thread alive until we run the collect data method.
        # On prod, the thread will keep alive in thread poll so don't worry about it
        sleep 1
      end
    end
    sleep 0.5
    threads.each { |t| Thread.kill t }
    log_result = track_log.inject({}) do |rs, value|
      Utils::MergeFilePath.merge_paths(rs, value)
    end
    expect(log_result).to eq({ 'file_path' => { count: 3 } })
    threads.map(&:join)
  end

  it 'keeps extra data' do
    described_class.start(time, track_block)
    described_class.track('file_path', { data: 1 })
    sleep 0.2
    log_result = track_log.inject({}) do |rs, value|
      Utils::MergeFilePath.merge_paths(rs, value)
    end
    expect(log_result).to eq({ 'file_path' => { count: 1, extra_data: { data: 1 }} })
  end
end
