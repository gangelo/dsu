# frozen_string_literal: true

RSpec.describe Dsu::Migration::Service do
  subject(:service) { described_class }

  let(:migrate_folder) { File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/migrate') }

  describe 'class constants' do
    describe 'MIGRATION_SERVICE_VERSION' do
      it 'exists' do
        expect(described_class).to be_const_defined(:MIGRATION_SERVICE_VERSION)
      end

      it 'returns the current mitration version' do
        expect(described_class::MIGRATION_SERVICE_VERSION).to eq 1.0
      end
    end
  end

  describe '#initialize' do
    it 'does not raise an error' do
      expect { service.new }.not_to raise_error
    end
  end

  describe '.migrate_folder' do
    it 'returns the lib/migrate folder' do
      expect(service.migrate_folder).to eq migrate_folder
    end
  end

  describe '.all_migration_files_info' do
    let(:expected_migration_files_info) do
      file_path = File.join(migrate_folder, '20230613121411_remove_and_add_configuration_attrs.rb')
      file_name = File.basename(file_path)
      migration_class = file_name.match(/\A\d+_(.+)\.rb\z/)[1].camelize
      [{
        migration_class: "Dsu::Migrate::#{migration_class}",
        path: file_path,
        require_file: file_path.sub(/\.[^.]+\z/, ''),
        version: 20230_6_13_121411 # rubocop:disable Style/NumericLiterals
      }]
    end

    it 'returns the information on all migration files' do
      expect(service.all_migration_files_info).to match_array expected_migration_files_info
    end
  end

  describe '.current_migration_version' do
    context 'when the migration version file does not exist' do
      it 'returns 0' do
        expect(service.current_migration_version).to eq 0
      end
    end

    context 'when the migration version file exists' do
      before do
        allow(described_class).to receive(:migrate_folder).and_return(temp_folder)
        migration_version_path = File.join(temp_folder, Dsu::Migration::MIGRATION_VERSION_FILE_NAME)
        allow(described_class).to receive(:migration_version_path).and_return(migration_version_path)
        File.write(migration_version_path, Psych.dump({ migration_version: 999 }))
      end

      after do
        File.delete(described_class.migration_version_path)
      end

      it 'returns the correct version' do
        expect(service.current_migration_version).to eq 999
      end
    end
  end

  describe '.migration_version_path' do
    it 'points to the migration version file' do
      expect(service.migration_version_path).to eq File.join(migrate_folder, Dsu::Migration::MIGRATION_VERSION_FILE_NAME)
    end
  end
end
