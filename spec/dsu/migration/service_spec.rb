# frozen_string_literal: true

RSpec.describe Dsu::Migration::Service do
  subject(:service) { described_class }

  before do
    FileUtils.cp_r('spec/fixtures/files/.dsu', Dsu::Support::Fileable.root_folder)
    entries_folder = Dsu::Support::Fileable.entries_folder
    FileUtils.cp_r('spec/fixtures/files/entries/.', entries_folder)
  end

  describe '#current_migration?' do
    context 'when the migration version is the current version' do
      subject(:migration_version) { create(:migration_version, :with_current_version) }

      it 'returns true' do
        expect(migration_version.current_migration?).to be(true)
      end
    end

    context 'when the migration version less than the current version' do
      subject(:migration_version) { create(:migration_version, version: 1 - Dsu::Migration::VERSION ) }

      it 'returns false' do
        expect(migration_version.current_migration?).to be(false)
      end
    end

    context 'when the migration version greater than the current version' do
      subject(:migration_version) { create(:migration_version, version: 1 + Dsu::Migration::VERSION ) }

      it 'returns false' do
        expect(migration_version.current_migration?).to be(false)
      end
    end
  end

  context 'when migrations should not be run' do
    subject(:migration_version) { create(:migration_version, :with_current_version) }

    specify 'the migration version file exists' do
      expect(migration_version).to exist
    end
  end

  context 'when migrations should be run' do
    subject(:migration_version) { build(:migration_version) }

    context 'when the migration file does not exist' do
      specify 'the migration version file does not exist' do
        expect(migration_version).not_to exist
      end
    end
  end
end
