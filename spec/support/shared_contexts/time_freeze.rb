# frozen_string_literal: true

RSpec.shared_context 'when time freeze needs to be freezed' do
  before do
    allow(Time).to receive(:now).and_return(time_utc.localtime)
  end

  let(:time_utc) { Time.parse('2022-10-01 00:00:00 UTC') }
  let(:local_time) { time_utc.localtime }
end

RSpec.configure do |config|
  config.include_context 'when time freeze needs to be freezed'
end
