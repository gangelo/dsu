# frozen_string_literal: true

RSpec.describe Dsu::Migrate::UpgradeToVersionTwoDotZeroDotZero do
  subject(:migration) { described_class.new }

  include_context 'with migrations'

  describe '#call' do
    #subject(:migration_service_version) { Dsu::Migration::Service[1.0] }

    # let(:migrate_folder) { Dsu::Migration::Service.migrate_folder }

    # before do
    #   all_migration_file_info = [
    #     migration_service_info_for(migration_file: '20230613121411_upgrade_to_version_two_dot_zero_dot_zero.rb', migrate_folder: migrate_folder)
    #   ]
    #   allow(Dsu::Migration::Service).to receive(:all_migration_files_info).and_return(all_migration_file_info)
    # end

    let(:start_migration_version) { 0 }
    let(:end_migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals

    it 'updates the migration file version' do
      migration.call
      expect(migration.current_migration_version).to eq(end_migration_version)
    end

    context 'when the configuration file does not exist' do
      before do
        File.delete(Dsu::Support::Fileable.config_path)
        migration.call
      end

      it 'creates a default configuration file' do
        expect(Dsu::Models::Configuration.exist?).to eq(true)
      end
    end

    xcontext 'when the configuration file exists' do
      before do
        File.write(Dsu::Support::Fileable.config_path, ConfigurationHelpers::CONFIGURATION_HASHES[start_migration_version.to_s].to_yaml)
        migration_service_version.call
      end

      it 'updates the configuration file' do
        expected_configuration_h =  {
          version: end_migration_version,
          editor: 'vim',
          entries_display_order: :asc,
          carry_over_entries_to_today: true,
          include_all: true,
          theme_name: 'default'
        }
        expect(Dsu::Models::Configuration.instance.to_h).to eq(expected_configuration_h)
      end
    end
  end
end
