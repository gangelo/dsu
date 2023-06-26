# frozen_string_literal: true

RSpec.describe Dsu::Migration::Service do
  subject(:service) { described_class }

  let(:migrate_folder) { Dsu::Support::Fileable.migrate_folder }

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

  describe '.all_migration_files_info' do
    let(:expected_migration_files_info) do
      [
        migration_service_info_for(migration_file: '20230613121411_upgrade_to_version_two_dot_zero_dot_zero.rb', migrate_folder: migrate_folder)
      ]
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
        migrate_folder = temp_folder
        allow(Dsu::Support::Fileable).to receive(:migrate_folder).and_return(migrate_folder)
        allow(Dsu::Support::Fileable).to receive(:migration_version_folder).and_return(migrate_folder)
        allow(Dsu::Support::Fileable).to receive(:migration_version_path).and_return(File.join(migrate_folder, Dsu::Support::Fileable::MIGRATION_VERSION_FILE_NAME))
        migration_version_path = Dsu::Support::Fileable.migration_version_path
        File.write(migration_version_path, Psych.dump({ migration_version: 999 }))
      end

      it 'returns the correct version' do
        expect(service.current_migration_version).to eq 999
      end
    end
  end
end
