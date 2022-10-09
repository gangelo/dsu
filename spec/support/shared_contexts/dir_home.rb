# frozen_string_literal: true

RSpec.shared_context 'dir home' do
  before do
    allow(Dir).to receive(:home).and_return('spec/support')
  end
end

RSpec.configure do |config|
  config.include_context 'dir home'
end
