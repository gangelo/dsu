# frozen_string_literal: true

RSpec.describe Dsu::Models::MigrationVersion do
  subject(:migration_version) { described_class.instance }

  let(:file_path) { temp_file.path }
  let(:input_file) { 'spec/fixtures/files/json_file_with_version.json' }
  let(:with_migration_version_file) do
    raise "The fixture file (#{input_file}) does not exist" unless File.exist?(input_file)

    file_hash = JSON.parse(File.read(input_file))
    File.write(Dsu::Support::Fileable.migration_version_path, JSON.pretty_generate(file_hash))
  end

  describe '#initialize' do
    context 'when the migration version file does not exist' do
      it 'sets the version to 0' do
        expect(migration_version.version).to eq(0)
      end
    end

    context 'when the migration version file exists' do
      before do
        with_migration_version_file
        migration_version.reload
      end

      it 'loads the migration version file' do
        expect(migration_version.version).to eq(123456789) # rubocop:disable Style/NumericLiterals
      end
    end
  end

  describe '#current_migration?' do
    context 'when the migration version file does not exist' do
      it 'returns false' do
        expect(migration_version.current_migration?).to be(false)
      end
    end

    context 'when the migration version file exists' do
      context 'when the migration version is the current version' do
        before do
          with_migration_version_file
          migration_version.reload
          stub_const('Dsu::Migration::VERSION', 123456789) # rubocop:disable Style/NumericLiterals
        end

        it 'returns true' do
          expect(migration_version.current_migration?).to be(true)
        end
      end
    end
  end
end
