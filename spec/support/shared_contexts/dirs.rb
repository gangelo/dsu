# frozen_string_literal: true

RSpec.shared_context 'with dirs' do
  include_context 'with tmp'

  before do
    allow(Dir).to receive(:home).and_return(home_folder)
    allow(Dir).to receive(:tmpdir).and_return(tmpdir_folder)
    allow(Dsu::Support::FolderLocations).to receive(:root_dir).and_return(entries_folder)
  end

  let(:home_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'home')).first }
  let(:tmpdir_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'tmpdir')).first }
  let(:entries_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'entries')).first }
end

RSpec.configure do |config|
  config.include_context 'with dirs'
end
