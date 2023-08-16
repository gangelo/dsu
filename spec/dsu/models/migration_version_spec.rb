# frozen_string_literal: true

# rubocop:disable Style/NumericLiterals
RSpec.describe Dsu::Models::MigrationVersion do
  describe '#initialize' do
    subject(:migration_version) { build(:migration_version) }

    context 'when the migration version file does not exist' do
      specify 'the migration version file does not exists' do
        expect(migration_version).not_to exist
      end

      it 'has a version of 0' do
        expect(migration_version.version).to eq(0)
      end
    end

    context 'when the migration version file exists' do
      specify 'the migration version file exists' do
        migration_version = create(:migration_version)
        expect(migration_version).to exist
      end

      it 'loads the migration version file' do
        create(:migration_version, version: 123456789)
        expect(described_class.new.version).to eq(123456789)
      end
    end
  end

  describe '#current_migration?' do
    context 'when the migration version is the current version' do
      subject(:migration_version) { build(:migration_version, :with_current_version) }

      it 'returns true' do
        expect(migration_version.current_migration?).to be(true)
      end
    end

    context 'when the migration version less than the current version' do
      subject(:migration_version) { build(:migration_version, version: 1 - Dsu::Migration::VERSION ) }

      it 'returns false' do
        expect(migration_version.current_migration?).to be(false)
      end
    end

    context 'when the migration version greater than the current version' do
      subject(:migration_version) { build(:migration_version, version: 1 + Dsu::Migration::VERSION ) }

      it 'returns false' do
        expect(migration_version.current_migration?).to be(false)
      end
    end
  end
end
# rubocop:enable Style/NumericLiterals
