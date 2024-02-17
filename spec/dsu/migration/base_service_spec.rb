# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
RSpec.describe Dsu::Migration::BaseService, type: :migration do
  subject(:base_service) { described_class.new(options: options) }

  let(:options) { { pretend: false } }

  describe '#initialize' do
    it 'does not raise an error' do
      expect { base_service }.to_not raise_error
    end
  end

  context 'when the required methods are not implemented' do
    describe '#migrate_if!' do
      subject(:base_service_error) { base_service.migrate_if! }

      let(:expected_error) { NotImplementedError }

      it_behaves_like 'an error is raised'
    end

    describe '.migrates_to_latest_migration_version?' do
      subject(:base_service_error) { described_class.migrates_to_latest_migration_version? }

      let(:expected_error) { NotImplementedError }

      it_behaves_like 'an error is raised'
    end

    describe '.from_migration_version' do
      subject(:base_service_error) { described_class.from_migration_version }

      let(:expected_error) { NotImplementedError }

      it_behaves_like 'an error is raised'
    end

    describe '.to_migration_version' do
      subject(:base_service_error) { described_class.to_migration_version }

      let(:expected_error) { NotImplementedError }

      it_behaves_like 'an error is raised'
    end
  end

  context 'when the required methods are implemented' do
    subject(:base_service) do
      service = Class.new(described_class) do
        class << self
          attr_accessor :from_migration_version, :to_migration_version
        end
      end.new(options: options)
      service.class.from_migration_version = from_migration_version
      service.class.to_migration_version = to_migration_version
      service
    end

    before do
      create(:migration_version, version: to_migration_version, options: options)
    end

    let(:from_migration_version) { 1 }
    let(:to_migration_version) { Dsu::Migration::VERSION }

    describe 'class methods' do
      describe '.from_migration_version' do
        let(:from_migration_version) { 1 }
        let(:to_migration_version) { 2 }

        it 'returns the from migration version' do
          expect(base_service.class.from_migration_version).to eq(from_migration_version)
        end
      end

      describe '.to_migration_version' do
        let(:from_migration_version) { 1 }
        let(:to_migration_version) { 2 }

        it 'returns the to migration version' do
          expect(base_service.class.to_migration_version).to eq(to_migration_version)
        end
      end

      describe '.migrates_to_latest_migration_version?' do
        context 'when the to migration version is not the latest' do
          let(:from_migration_version) { 1 }
          let(:to_migration_version) { 1 + Dsu::Migration::VERSION }

          it 'returns false' do
            expect(base_service.class.migrates_to_latest_migration_version?).to be false
          end
        end

        context 'when the to migration version is the latest' do
          let(:from_migration_version) { 1 }
          let(:to_migration_version) { Dsu::Migration::VERSION }

          it 'returns true' do
            expect(base_service.class.migrates_to_latest_migration_version?).to be true
          end
        end
      end
    end

    describe 'instance methods' do
      describe '#migrate_if!' do
        before do
          stub_const('Dsu::Migration::VERSION', to_migration_version)
          mock_migration_version_for(version: from_migration_version)
          create(:migration_version, version: migration_version, options: options)
          base_service.migrate_if!
        end

        context 'when the current migration version is equal to the from migration version' do
          let(:migration_version) { from_migration_version }
          let(:from_migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals
          let(:to_migration_version) { 20240210161248 } # rubocop:disable Style/NumericLiterals

          it 'creates a backup of the current dsu folder and updates the migration version' do
            expected_backup_folder = Dsu::Support::Fileable.backup_folder_for(migration_version: migration_version)
            expect(Dir.exist?(expected_backup_folder)).to be true
            expect(Dsu::Models::MigrationVersion.new.version).to eq to_migration_version
          end
        end

        context 'when the current migration version is not equal to the from migration version' do
          let(:migration_version) { to_migration_version }
          let(:from_migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals
          let(:to_migration_version) { 20240210161248 } # rubocop:disable Style/NumericLiterals

          it 'does not create a backup of the current dsu folder and does not update the migration version' do
            expected_backup_folder = Dsu::Support::Fileable.backup_folder_for(migration_version: from_migration_version)
            expect(Dir.exist?(expected_backup_folder)).to be false
            expect(Dsu::Models::MigrationVersion.new.version).to_not eq from_migration_version
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
