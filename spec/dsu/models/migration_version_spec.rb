# frozen_string_literal: true

# rubocop:disable Style/NumericLiterals
RSpec.describe Dsu::Models::MigrationVersion do
  subject(:migration_version) { build(:migration_version) }

  describe '#initialize' do
    context 'when the migration version file does not exist' do
      it 'has a version of 0' do
        expect(migration_version.version).to eq(0)
      end
    end

    context 'when the migration version file exists' do
      subject(:migration_version) { create(:migration_version, version: 123456789) }

      specify 'the migration version file exists' do
        expect(migration_version).to exist
      end

      it 'loads the migration version file' do
        expect(migration_version.version).to eq(123456789)
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
