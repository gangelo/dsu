# frozen_string_literal: true

RSpec.shared_context 'when dir mock and cleanup is needed' do
  before do
    # Mock Dir.home and Dir.tmpdir to return the temporary directories
    allow(Dir).to receive_messages(home: temp_folder, tmpdir: temp_folder)
    allow(Tempfile).to receive(:new).with('dsu').and_return(temp_file)

    FileUtils.mkdir_p(Dsu::Support::Fileable.root_folder)

    dsu_folder = File.join(temp_folder, 'dsu')
    FileUtils.mkdir_p(dsu_folder)
    allow(Dsu::Support::Fileable).to receive_messages(migration_version_folder: dsu_folder, migration_version_path: File.join(dsu_folder, Dsu::Support::Fileable::MIGRATION_VERSION_FILE_NAME))

    fixture_path = File.join('spec', 'fixtures', 'files', 'current_project.json')
    FileUtils.cp(fixture_path, Dsu::Support::Fileable.current_project_file)

    # Create a default project folder.
    default_project_folder = File.join(Dsu::Support::Fileable.projects_folder,
      Dsu::Models::Configuration::DEFAULT_CONFIGURATION[:default_project])
    FileUtils.mkdir_p(default_project_folder)

    # Create the default project.json file.
    project_json = File.join('spec', 'fixtures', 'files', 'project.json')
    FileUtils.cp(project_json, File.join(default_project_folder, File.basename(project_json)))

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
