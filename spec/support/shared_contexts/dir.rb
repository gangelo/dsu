# frozen_string_literal: true

RSpec.shared_context 'with dir' do
  before do
    allow(Dir).to receive(:home).and_return(Dir.tmpdir)
  end
end

RSpec.configure do |config|
  config.include_context 'with dir'
end
