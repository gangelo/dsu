# frozen_string_literal: true

RSpec.describe 'Migrations' do
  subject(:current_migration_service) { Dsu::Migration::Service[:current] }

  shared_context 'with migrations'

  before do
    puts "Copying test data from: #{source_folder}..."
    puts "Copying test data to: #{destination_folder}..."
    FileUtils.cp_r("#{source_folder}/.", destination_folder)

    allow(Dsu::Migration::Service).to receive(:migration_version_folder).and_return(destination_folder)
    migration_version_file = Dsu::Migration::MIGRATION_VERSION_FILE_NAME
    allow(Dsu::Migration::Service).to receive(:migration_version_path).and_return(File.join(destination_folder, migration_version_file))
  end

  after do
    files_and_folders_to_delete = "#{destination_folder}/."
    puts "Deleting test data from: #{files_and_folders_to_delete}"
    FileUtils.rm_rf(files_and_folders_to_delete)
  end

  let(:gem_dir) { Gem.loaded_specs['dsu'].gem_dir }

  let(:source_folder) do
    source_folder = File.join(gem_dir, 'spec/dsu/test_data')
    File.join(source_folder, start_migration_version.to_s)
  end

  let(:destination_folder) do
    File.join(temp_folder, 'dsu')
  end

  describe 'migrating from version 0 to version 20230613121411' do
    subject(:migration_service_version) { Dsu::Migration::Service[1.0] }

    let(:start_migration_version) { 0 }
    let(:end_migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals

    it 'updates the migration file version' do
      migration_service_version.run_migrations!
      expect(migration_service_version.current_migration_version).to eq(end_migration_version)
    end

    context 'when the configuration file exists' do
      before do
        migration_service_version.run_migrations!
      end

      it 'updates the configuration file with the correct version' do
        expect(Dsu::Models::Configuration.instance.version).to eq(end_migration_version)
      end
    end

    context 'when the configuration file does not exist' do
      before do
        File.delete(Dsu::Support::Fileable.config_path)
        migration_service_version.run_migrations!
      end

      it 'creates a default configuration file' do
        default_configuration_h = Dsu::Models::Configuration::DEFAULT_CONFIGURATION
        configuration = Dsu::Models::Configuration.instance
        expect(configuration.to_h).to eq(default_configuration_h)
      end
    end

    context 'when the configuration file exists' do
      before do
        old_configuration_h = {
          editor: 'vim',
          entries_display_order: 'asc',
          entries_file_name: '%Y-%m-%d.json',
          entries_folder: '/Users/gangelo/dsu/entries',
          carry_over_entries_to_today: true,
          include_all: true
        }
        File.write(Dsu::Support::Fileable.config_path, old_configuration_h.to_yaml)
        migration_service_version.run_migrations!
      end

      let(:expected_configuration_h) do
        {
          version: end_migration_version,
          editor: 'vim',
          entries_display_order: :asc,
          carry_over_entries_to_today: true,
          include_all: true,
          theme_name: 'default'
        }
      end

      it 'updates the configuration file' do
        configuration = Dsu::Models::Configuration.instance
        expect(configuration.to_h).to eq(expected_configuration_h)
      end
    end
  end
end
