# frozen_string_literal: true

RSpec.shared_context 'with dir' do
  before do
    stub_dir_home
    stub_dir_tmpdir
  end

  let(:stub_dir_home) do
    allow(Dir).to receive(:home).and_return('spec/support/test_folders')
  end

  let(:stub_dir_tmpdir) do
    allow(Dir).to receive(:tmpdir).and_return('spec/support/test_folders/tmp')
  end
end

RSpec.configure do |config|
  config.include_context 'with dir'
end
