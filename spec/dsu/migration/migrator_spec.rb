# frozen_string_literal: true

RSpec.describe Dsu::Migration::Migrator, type: :migration do
  before do
    mock_migration_version_for(version: migration_version)
    migration_services.each do |migration_service|
      allow(migration_service).to receive(:run_migration!).and_call_original
    end
  end

  let(:options) { { pretend: false } }
  let(:migration_services) do
    [
      v20230613121411_migration_service,
      v20240210161248_migration_service
    ]
  end
  let(:v20230613121411_migration_service) { Dsu::Migration::V20230613121411::Service.new(options: options) }
  let(:v20240210161248_migration_service) { Dsu::Migration::V20240210161248::Service.new(options: options) }

  describe '.migrate_if!' do
    shared_examples 'migrations for version 20230613121411 ran' do
      it 'migrations to version 20230613121411' do
        expect(v20230613121411_migration_service).to have_received(:run_migration!)
      end
    end

    shared_examples 'migrations for version 20240210161248 ran' do
      it 'migrations to version 20240210161248' do
        expect(v20240210161248_migration_service).to have_received(:run_migration!)
      end
    end

    shared_examples 'migrations for version 20230613121411 DID NOT run' do
      it 'migrations to version 20230613121411' do
        expect(v20230613121411_migration_service).to_not have_received(:run_migration!)
      end
    end

    shared_examples 'migrations for version 20240210161248 DID NOT run' do
      it 'migrations to version 20240210161248' do
        expect(v20240210161248_migration_service).to_not have_received(:run_migration!)
      end
    end

    context 'when the migration version is 0' do
      before do
        create(:migration_version, version: migration_version, options: options)
        described_class.migrate_if!(migration_services: migration_services)
      end

      let(:migration_version) { 0 }

      it_behaves_like 'migrations for version 20230613121411 ran'
      it_behaves_like 'migrations for version 20240210161248 ran'
    end

    context 'when the migration version is 20230613121411' do
      before do
        create(:migration_version, version: migration_version, options: options)
        described_class.migrate_if!(migration_services: migration_services)
      end

      let(:migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals

      it_behaves_like 'migrations for version 20230613121411 DID NOT run'
      it_behaves_like 'migrations for version 20240210161248 ran'
    end

    context 'when the migration version is 20240210161248' do
      before do
        create(:migration_version, version: migration_version, options: options)
        described_class.migrate_if!(migration_services: migration_services)
      end

      let(:migration_version) { 20240210161248 } # rubocop:disable Style/NumericLiterals

      it_behaves_like 'migrations for version 20230613121411 DID NOT run'
      it_behaves_like 'migrations for version 20240210161248 DID NOT run'
    end

    context 'when there is no migration service to migrate to the latest migration version' do
      subject(:migrator) { described_class.migrate_if!(migration_services: migration_services) }

      before do
        create(:migration_version, version: 0, options: options)
      end

      let(:migration_version) { 0 }
      let(:migration_services) { [] }
      let(:expected_error) { "No migration service handles the current migration: #{Dsu::Migration::VERSION}." }

      it 'displays an error message' do
        expect { migrator }.to output(/#{expected_error}/).to_stdout
      end
    end
  end
end
