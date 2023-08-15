# frozen_string_literal: true

RSpec.shared_context 'when dir mock and cleanup is needed' do
  before do
    # Mock Dir.home and Dir.tmpdir to return the temporary directories
    allow(Dir).to receive(:home).and_return(temp_folder)
    allow(Dir).to receive(:tmpdir).and_return(temp_folder)
    allow(Tempfile).to receive(:new).with('dsu').and_return(temp_file)

    FileUtils.mkdir_p(Dsu::Support::Fileable.root_folder)

    migrate_folder = File.join(temp_folder, 'dsu')
    FileUtils.mkdir_p(migrate_folder)
    allow(Dsu::Support::Fileable).to receive(:migrate_folder).and_return(migrate_folder)
    allow(Dsu::Support::Fileable).to receive(:migration_version_folder).and_return(migrate_folder)
    allow(Dsu::Support::Fileable).to receive(:migration_version_path).and_return(File.join(migrate_folder, Dsu::Support::Fileable::MIGRATION_VERSION_FILE_NAME))

    FileUtils.mkdir_p(Dsu::Support::Fileable.config_folder)
    FileUtils.mkdir_p(Dsu::Support::Fileable.entries_folder)
    FileUtils.mkdir_p(Dsu::Support::Fileable.themes_folder)

    create(:color_theme)
  end

  after do
    # Clean up the files and directories created within the temporary directory.
    FileUtils.rm_rf(File.join(temp_folder, 'dsu'))
    FileUtils.rm_rf(File.join(temp_folder, '.dsu'))
  end

  let(:temp_folder) { Dir.tmpdir }
  let(:temp_file) { Tempfile.new('dsu', temp_folder) }
end

RSpec.configure do |config|
  config.include_context 'when dir mock and cleanup is needed'
end
